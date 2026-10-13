/// Feature flag identifiers and client-side evaluations.
abstract final class FeatureFlags {
  /// Whether biometric app-locking is enabled.
  static bool enableBiometrics = true;

  /// Whether offline caching & sync queue are enabled.
  static bool enableOfflineSync = true;

  /// Whether predictive back gesture is enabled on Android 14+.
  static bool enablePredictiveBack = true;

  /// Whether in-app diagnostic console (Talker screen) is accessible in debug builds.
  static bool enableInAppDiagnostics = true;

  /// Dynamically toggle a feature flag for testing or runtime configuration.
  static void setOverride({required String flagKey, required bool value}) {
    switch (flagKey) {
      case 'enableBiometrics':
        enableBiometrics = value;
      case 'enableOfflineSync':
        enableOfflineSync = value;
      case 'enablePredictiveBack':
        enablePredictiveBack = value;
      case 'enableInAppDiagnostics':
        enableInAppDiagnostics = value;
      default:
        break;
    }
  }
}
