import 'dart:async';
import 'dart:convert';

import 'package:buzzer_app/core/constants/app_durations.dart';
import 'package:buzzer_app/core/constants/storage_keys.dart';
import 'package:buzzer_app/core/security/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class TokenManager {
  TokenManager({
    required TokenStorage tokenStorage,
    required SharedPreferences preferences,
  }) : _tokenStorage = tokenStorage,
       _preferences = preferences;

  final TokenStorage _tokenStorage;
  final SharedPreferences _preferences;

  // IN-MEMORY ONLY storage for access token
  String? _inMemoryAccessToken;
  bool _hasStoredRefreshToken = false;

  // Single-flight refresh coordination
  Completer<String?>? _refreshCompleter;

  // Reactive authentication stream
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  Stream<bool> get isAuthenticatedStream => _authStateController.stream;

  bool get isAuthenticated =>
      _hasStoredRefreshToken ||
      (_inMemoryAccessToken != null && _inMemoryAccessToken!.isNotEmpty);

  Future<void> initialize() async {
    final hasRunBefore =
        _preferences.getBool(StorageKeys.hasRunBefore) ?? false;
    if (!hasRunBefore) {
      // First launch: wipe stale Keychain entries on iOS
      await _tokenStorage.clearAll();
      await _preferences.setBool(StorageKeys.hasRunBefore, true);
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    _hasStoredRefreshToken = refreshToken != null && refreshToken.isNotEmpty;
    _authStateController.add(_hasStoredRefreshToken);
  }

  /// Returns the current in-memory access token.
  String? getAccessToken() => _inMemoryAccessToken;

  /// Returns the stored refresh token from secure storage.
  Future<String?> getRefreshToken() => _tokenStorage.getRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _inMemoryAccessToken = accessToken;
    await _tokenStorage.saveRefreshToken(refreshToken);
    _hasStoredRefreshToken = refreshToken.isNotEmpty;
    _authStateController.add(true);
  }

  /// Updates only the in-memory access token (e.g. after refresh without rotation).
  void updateAccessToken(String accessToken) {
    _inMemoryAccessToken = accessToken;
    _authStateController.add(true);
  }

  /// Wipes all in-memory and persistent token state.
  Future<void> clearTokens() async {
    _inMemoryAccessToken = null;
    _hasStoredRefreshToken = false;
    await _tokenStorage.deleteRefreshToken();
    _authStateController.add(false);
  }

  /// Proactively inspects JWT access token expiration.
  /// Returns `true` if token is expired or within the ~60s safety buffer window.
  bool isTokenExpiredOrNearExpiry() {
    final token = _inMemoryAccessToken;
    if (token == null) return true;

    final expiry = extractJwtExpiry(token);
    if (expiry == null) {
      return false; // If not a valid JWT, rely on HTTP 401 interceptor
    }

    final threshold = DateTime.now().add(AppDurations.tokenExpirySafetyWindow);
    return expiry.isBefore(threshold);
  }

  /// Executes a single-flight refresh operation.
  ///
  /// If a refresh is already in progress, concurrent callers await the active operation.
  /// [refreshCall] performs the actual HTTP exchange and returns `(newAccessToken, newRefreshToken)`.
  Future<String?> singleFlightRefresh({
    required Future<(String accessToken, String? newRefreshToken)> Function(
      String currentRefreshToken,
    )
    refreshCall,
    required Future<void> Function() onRefreshFailed,
  }) async {
    // 1. If refresh is already underway, await existing completer
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final currentRefreshToken = await _tokenStorage.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw StateError('No refresh token available');
      }

      // Execute network refresh call
      final (newAccessToken, newRefreshToken) = await refreshCall(
        currentRefreshToken,
      );

      // Save new access token to memory
      _inMemoryAccessToken = newAccessToken;

      // Handle refresh token ROTATION if new refresh token was provided
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _tokenStorage.saveRefreshToken(newRefreshToken);
      }

      _hasStoredRefreshToken = true;
      _authStateController.add(true);
      _refreshCompleter?.complete(newAccessToken);
      return newAccessToken;
    } catch (error) {
      // Hard failure path: token reuse detected or refresh rejected
      await clearTokens();
      await onRefreshFailed();
      _refreshCompleter?.completeError(error);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Decodes JWT expiration date safely from the payload without third-party dependencies.
  static DateTime? extractJwtExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalizedPayload));
      final jsonMap = json.decode(payloadString) as Map<String, dynamic>;

      if (jsonMap.containsKey('exp') && jsonMap['exp'] is num) {
        final expSeconds = (jsonMap['exp'] as num).toInt();
        return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
      }
    } catch (_) {
      // Silently fall back if token is opaque or malformed
    }
    return null;
  }

  void dispose() {
    _authStateController.close();
  }
}
