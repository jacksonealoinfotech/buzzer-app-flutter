/// Typed keys for persistent local storage and secure credentials.
abstract final class StorageKeys {
  // Local (Unencrypted / Shared Preferences) Keys
  static const String themeMode = 'pref_theme_mode';
  static const String localeLanguageCode = 'pref_locale_language_code';
  static const String hasCompletedOnboarding = 'pref_has_completed_onboarding';
  static const String hasRunBefore = 'pref_has_run_before'; // Used to detect fresh install & clear stale keychain
  static const String lastActiveTimestamp = 'pref_last_active_timestamp';

  // Secure Storage Keys (Keystore / Keychain)
  // Note: Access token is kept IN MEMORY ONLY per OWASP MASVS policy.
  static const String refreshToken = 'sec_refresh_token';
  static const String databaseEncryptionKey = 'sec_db_encryption_key';
  static const String biometricToken = 'sec_biometric_token';
}
