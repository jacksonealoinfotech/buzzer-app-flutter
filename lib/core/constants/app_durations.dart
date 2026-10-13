/// Centralized animation durations, timeouts, and throttling values.
abstract final class AppDurations {
  // Micro-interactions & UI Animations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // Debouncing & Throttling
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration buttonThrottle = Duration(milliseconds: 600);

  // Security & Sessions
  static const Duration tokenExpirySafetyWindow = Duration(seconds: 60);
  static const Duration sessionIdleTimeout = Duration(minutes: 15);
  static const Duration backgroundAutoLockTimeout = Duration(minutes: 5);

  // Network
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration retryBaseDelay = Duration(milliseconds: 500);
}
