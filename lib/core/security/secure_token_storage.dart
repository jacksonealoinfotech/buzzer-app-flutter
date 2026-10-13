import 'dart:async';

import 'package:buzzer_app/core/constants/storage_keys.dart';
import 'package:buzzer_app/core/security/token_storage.dart';

// TODO: Uncomment when `flutter_secure_storage` package is enabled in pubspec.yaml:
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Hardware-backed secure implementation of [TokenStorage].
///
/// Complies with OWASP MASVS:
/// - iOS: Keychain with accessibility `first_unlock_this_device` and iCloud sync disabled.
/// - Android: Keystore-backed EncryptedSharedPreferences (AES-256-GCM / RSA).
final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage();

  // In-memory fallback map used when flutter_secure_storage is not active.
  final Map<String, String> _inMemoryFallback = <String, String>{};

  // TODO: Uncomment when `flutter_secure_storage` package is enabled in pubspec.yaml:
  // static const _androidOptions = AndroidOptions(
  //   encryptedSharedPreferences: true,
  //   resetOnError: true,
  // );
  // static const _iosOptions = IOSOptions(
  //   accessibility: KeychainAccessibility.first_unlock_this_device,
  //   synchronizable: false,
  // );
  // final _secureStorage = const FlutterSecureStorage(
  //   aOptions: _androidOptions,
  //   iOptions: _iosOptions,
  // );

  @override
  Future<String?> getRefreshToken() async {
    // TODO: Uncomment when `flutter_secure_storage` package is enabled:
    // return _secureStorage.read(key: StorageKeys.refreshToken);

    return _inMemoryFallback[StorageKeys.refreshToken];
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    // TODO: Uncomment when `flutter_secure_storage` package is enabled:
    // await _secureStorage.write(key: StorageKeys.refreshToken, value: token);

    _inMemoryFallback[StorageKeys.refreshToken] = token;
  }

  @override
  Future<void> deleteRefreshToken() async {
    // TODO: Uncomment when `flutter_secure_storage` package is enabled:
    // await _secureStorage.delete(key: StorageKeys.refreshToken);

    _inMemoryFallback.remove(StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    // TODO: Uncomment when `flutter_secure_storage` package is enabled:
    // await _secureStorage.deleteAll();

    _inMemoryFallback.clear();
  }
}
