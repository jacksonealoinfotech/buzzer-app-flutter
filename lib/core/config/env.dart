import 'package:buzzer_app/core/config/flavor.dart';

/// Application runtime configuration populated via `--dart-define-from-file` or compile-time defaults.
///
/// NOTE on Secrets:
/// In client-side applications (Flutter), compiled binaries can always be reverse-engineered.
/// True application secrets (e.g., database master passwords, private signing keys) MUST remain on backend servers.
/// Public/client credentials (API keys, Sentry DSNs, SPKI hashes) should be loaded through environment variables.
abstract final class AppEnv {
  /// Active flavor for current build.
  static late final Flavor flavor;

  /// Base API URL. Defaults to flavor-specific URL if not overridden via `--dart-define`.
  static String get apiBaseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: '').isEmpty
      ? flavor.defaultBaseUrl
      : const String.fromEnvironment('API_BASE_URL');

  /// Network connect timeout in seconds.
  static int get connectTimeoutSeconds =>
      const int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 15);

  /// Network receive timeout in seconds.
  static int get receiveTimeoutSeconds =>
      const int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 15);

  /// Whether verbose diagnostic logging is enabled.
  static bool get enableLogging =>
      const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  /// Whether SSL Certificate & Public-Key pinning is actively enforced.
  static bool get enableCertificatePinning =>
      const bool.fromEnvironment('ENABLE_CERT_PINNING', defaultValue: false);

  /// Sentry DSN (optional).
  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  /// Primary SHA-256 SPKI public key hash for certificate pinning.
  static String get primaryCertPin => const String.fromEnvironment(
    'PRIMARY_CERT_PIN',
    defaultValue: 'WoiWRyIOVNa9ihaBciRSC7XHjliYS9VwUGOIud4PB18=',
  );

  /// Backup SHA-256 SPKI public key hash for certificate pinning rotation.
  static String get backupCertPin => const String.fromEnvironment(
    'BACKUP_CERT_PIN',
    defaultValue: 'r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=',
  );

  /// Initialize environment with target flavor.
  static void initialize({required Flavor appFlavor}) {
    flavor = appFlavor;
  }
}
