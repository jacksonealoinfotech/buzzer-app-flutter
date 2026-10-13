/// Contract for remote crash and diagnostic error telemetry.
abstract interface class CrashReportingService {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  Future<void> setCustomKey(String key, Object value);
  Future<void> log(String message);
}

/// Production implementation of [CrashReportingService].
class DefaultCrashReportingService implements CrashReportingService {
  // TODO: Uncomment when `firebase_crashlytics` is enabled in pubspec.yaml:
  // final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    // TODO: Uncomment when `firebase_crashlytics` is active:
    // await _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    // TODO: Uncomment:
    // await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> log(String message) async {
    // TODO: Uncomment:
    // await _crashlytics.log(message);
  }
}
