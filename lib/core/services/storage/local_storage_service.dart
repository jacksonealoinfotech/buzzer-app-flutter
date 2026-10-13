import 'package:shared_preferences/shared_preferences.dart';

/// Contract for unencrypted key-value persistent storage.
abstract interface class LocalStorageService {
  String? getString(String key);
  Future<bool> setString(String key, String value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  double? getDouble(String key);
  Future<bool> setDouble(String key, double value);

  List<String>? getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  Future<bool> remove(String key);
  Future<bool> clear();
  bool containsKey(String key);
}

/// Production implementation of [LocalStorageService] backed by [SharedPreferences].
final class DefaultLocalStorageService implements LocalStorageService {
  DefaultLocalStorageService({required SharedPreferences preferences})
      : _preferences = preferences;

  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  int? getInt(String key) => _preferences.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  double? getDouble(String key) => _preferences.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  @override
  List<String>? getStringList(String key) => _preferences.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _preferences.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> clear() => _preferences.clear();

  @override
  bool containsKey(String key) => _preferences.containsKey(key);
}
