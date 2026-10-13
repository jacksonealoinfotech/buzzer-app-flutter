/// Abstract interface class for fetching remote configuration and feature flags.
abstract interface class RemoteConfigHook {
  /// Initializes the remote configuration provider.
  Future<void> initialize();

  /// Fetches and activates latest remote configuration parameters.
  Future<bool> fetchAndActivate();

  /// Gets a boolean value by key.
  bool getBool(String key, {bool defaultValue = false});

  /// Gets a string value by key.
  String getString(String key, {String defaultValue = ''});

  /// Gets an integer value by key.
  int getInt(String key, {int defaultValue = 0});
}

/// Default in-memory implementation of [RemoteConfigHook].
///
/// Can be swapped for Firebase Remote Config in production:
/// ```dart
/// // TODO: Uncomment when firebase_remote_config is added:
/// // import 'package:firebase_remote_config/firebase_remote_config.dart';
/// // class FirebaseRemoteConfigService implements RemoteConfigHook { ... }
/// ```
final class DefaultRemoteConfigService implements RemoteConfigHook {
  final Map<String, Object> _defaults = <String, Object>{};

  @override
  Future<void> initialize() async {
    // Set in-app fallback values
    _defaults.addAll(<String, Object>{
      'min_supported_version': '1.0.0',
      'maintenance_mode': false,
      'force_update_required': false,
    });
  }

  @override
  Future<bool> fetchAndActivate() async {
    // In default mock implementation, returns true immediately.
    return true;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final value = _defaults[key];
    return value is bool ? value : defaultValue;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _defaults[key];
    return value is String ? value : defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final value = _defaults[key];
    return value is int ? value : defaultValue;
  }
}
