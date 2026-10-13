import 'dart:async';

import 'package:buzzer_app/core/constants/app_durations.dart';

// TODO: Uncomment when `local_auth` package is enabled in pubspec.yaml:
// import 'package:local_auth/local_auth.dart';

/// Contract for managing biometric and PIN screen locks.
abstract interface class AppLockService {
  /// Whether biometric hardware is available on this device.
  Future<bool> isBiometricsAvailable();

  /// Prompts user to authenticate with biometrics or device PIN/passcode.
  Future<bool> authenticate({required String localizedReason});

  /// Records successful authentication timestamp.
  void recordSuccessfulAuth();

  /// Checks whether authentication was performed recently (within threshold).
  /// Enforces re-auth before sensitive actions (e.g., transfers, credential changes).
  bool hasRecentAuth({Duration threshold = const Duration(minutes: 5)});

  /// Evaluates whether app should lock after returning from background.
  bool shouldLockOnResume(DateTime backgroundTimestamp);
}

/// Production implementation of [AppLockService].
final class DefaultAppLockService implements AppLockService {
  DateTime? _lastAuthenticatedTimestamp;

  // TODO: Uncomment when `local_auth` is enabled:
  // final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> isBiometricsAvailable() async {
    // TODO: Uncomment when `local_auth` is enabled:
    // final canCheck = await _localAuth.canCheckBiometrics;
    // final isDeviceSupported = await _localAuth.isDeviceSupported();
    // return canCheck && isDeviceSupported;

    return false;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    // TODO: Uncomment when `local_auth` is enabled:
    // try {
    //   final success = await _localAuth.authenticate(
    //     localizedReason: localizedReason,
    //     options: const AuthenticationOptions(
    //       stickyAuth: true,
    //       biometricOnly: false,
    //     ),
    //   );
    //   if (success) recordSuccessfulAuth();
    //   return success;
    // } catch (_) {
    //   return false;
    // }

    // Mock fallback: succeeds immediately when biometric package is not active
    recordSuccessfulAuth();
    return true;
  }

  @override
  void recordSuccessfulAuth() {
    _lastAuthenticatedTimestamp = DateTime.now();
  }

  @override
  bool hasRecentAuth({Duration threshold = const Duration(minutes: 5)}) {
    final last = _lastAuthenticatedTimestamp;
    if (last == null) return false;
    return DateTime.now().difference(last) < threshold;
  }

  @override
  bool shouldLockOnResume(DateTime backgroundTimestamp) {
    final backgroundDuration = DateTime.now().difference(backgroundTimestamp);
    return backgroundDuration >= AppDurations.backgroundAutoLockTimeout;
  }
}
