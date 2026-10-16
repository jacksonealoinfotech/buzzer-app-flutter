import 'dart:async';

import 'package:buzzer_app/core/constants/app_durations.dart';

import 'package:local_auth/local_auth.dart';

abstract interface class AppLockService {
  Future<bool> isBiometricsAvailable();

  Future<bool> authenticate({required String localizedReason});

  void recordSuccessfulAuth();

  bool hasRecentAuth({Duration threshold = const Duration(minutes: 5)});

  bool shouldLockOnResume(DateTime backgroundTimestamp);
}

final class DefaultAppLockService implements AppLockService {
  DateTime? _lastAuthenticatedTimestamp;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> isBiometricsAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
      );
      if (success) recordSuccessfulAuth();
      return success;
    } catch (_) {
      return false;
    }
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
