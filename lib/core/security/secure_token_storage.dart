import 'dart:async';

import 'package:buzzer_app/core/constants/storage_keys.dart';
import 'package:buzzer_app/core/security/token_storage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage();

  final Map<String, String> _inMemoryFallback = <String, String>{};

  static const AndroidOptions _androidOptions = AndroidOptions.defaultOptions;
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );
  final _secureStorage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
    _inMemoryFallback[StorageKeys.refreshToken] = token;
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    _inMemoryFallback.remove(StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    _inMemoryFallback.clear();
  }
}
