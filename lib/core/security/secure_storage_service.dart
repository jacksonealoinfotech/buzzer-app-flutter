import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for persistent hardware-backed key-value encryption.
abstract interface class SecureStorageService {
  /// Reads a sensitive string by [key].
  Future<String?> read(String key);

  /// Writes a sensitive string by [key].
  Future<void> write(String key, String value);

  /// Deletes a key from secure storage.
  Future<void> delete(String key);

  /// Clears all keys in secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists.
  Future<bool> containsKey(String key);
}

/// Production implementation of [SecureStorageService].
final class DefaultSecureStorageService implements SecureStorageService {
  DefaultSecureStorageService();

  final Map<String, String> _fallbackStore = <String, String>{};
  static const AndroidOptions _androidOptions = AndroidOptions.defaultOptions;
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );
  final _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);

    _fallbackStore[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);

    _fallbackStore.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();

    _fallbackStore.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
