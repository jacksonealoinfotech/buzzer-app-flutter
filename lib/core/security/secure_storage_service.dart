import 'dart:async';

// TODO: Uncomment when `flutter_secure_storage` package is enabled in pubspec.yaml:
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // TODO: Uncomment when `flutter_secure_storage` is active:
  // static const _androidOptions = AndroidOptions(encryptedSharedPreferences: true);
  // static const _iosOptions = IOSOptions(
  //   accessibility: KeychainAccessibility.first_unlock_this_device,
  //   synchronizable: false,
  // );
  // final _storage = const FlutterSecureStorage(aOptions: _androidOptions, iOptions: _iosOptions);

  @override
  Future<String?> read(String key) async {
    // TODO: Uncomment when `flutter_secure_storage` is active:
    // return _storage.read(key: key);

    return _fallbackStore[key];
  }

  @override
  Future<void> write(String key, String value) async {
    // TODO: Uncomment when `flutter_secure_storage` is active:
    // await _storage.write(key: key, value: value);

    _fallbackStore[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    // TODO: Uncomment when `flutter_secure_storage` is active:
    // await _storage.delete(key: key);

    _fallbackStore.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    // TODO: Uncomment when `flutter_secure_storage` is active:
    // await _storage.deleteAll();

    _fallbackStore.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    // TODO: Uncomment when `flutter_secure_storage` is active:
    // return _storage.containsKey(key: key);

    return _fallbackStore.containsKey(key);
  }
}
