import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:buzzer_app/core/config/flavor.dart';

/// Policy dictating response when device integrity compromise is detected.
enum IntegrityPolicy {
  /// Allow execution without restrictions (standard for development).
  allow,

  /// Display security warning banner to user but continue operating.
  warn,

  /// Block sensitive features (e.g. biometrics, checkout, token persistence).
  blockSensitiveFeatures,

  /// Terminate session and prohibit application access completely.
  blockApp,
}

/// Result record holding hardware and software integrity checks.
final class IntegrityReport {
  const IntegrityReport({
    required this.isRootedOrJailbroken,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.isHookingDetected,
    required this.isTampered,
  });

  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final bool isHookingDetected;
  final bool isTampered;

  bool get hasAnyViolation =>
      isRootedOrJailbroken ||
      isEmulator ||
      isDebuggerAttached ||
      isHookingDetected ||
      isTampered;
}

/// Abstract contract for runtime device security & RASP protection.
abstract interface class DeviceIntegrityService {
  /// Evaluates device and environment state.
  Future<IntegrityReport> evaluateIntegrity();

  /// Determines whether current application should block execution based on flavor policy.
  bool shouldBlockExecution(IntegrityReport report, Flavor flavor);
}

/// Production implementation of [DeviceIntegrityService].
///
/// Integrates with RASP (Runtime Application Self-Protection) solutions such as
/// Talsec freeRASP or DexGuard.
final class DefaultDeviceIntegrityService implements DeviceIntegrityService {
  // TODO: Uncomment when `freerasp` package is added:
  // import 'package:freerasp/freerasp.dart';

  @override
  Future<IntegrityReport> evaluateIntegrity() async {
    // In debug mode, debugger is naturally attached.
    final isDebugger = kDebugMode;

    // TODO: Connect to native RASP SDK listeners (freeRASP / root_detector):
    // const isJailbroken = await FlutterRootBeer.isRooted();

    return IntegrityReport(
      isRootedOrJailbroken: false,
      isEmulator: false,
      isDebuggerAttached: isDebugger,
      isHookingDetected: false,
      isTampered: false,
    );
  }

  @override
  bool shouldBlockExecution(IntegrityReport report, Flavor flavor) {
    final policy = getPolicyForFlavor(flavor);
    return switch (policy) {
      IntegrityPolicy.allow => false,
      IntegrityPolicy.warn => false,
      IntegrityPolicy.blockSensitiveFeatures => false,
      IntegrityPolicy.blockApp => report.hasAnyViolation,
    };
  }

  /// Policy mapping per environment flavor.
  static IntegrityPolicy getPolicyForFlavor(Flavor flavor) {
    return switch (flavor) {
      Flavor.dev => IntegrityPolicy.allow,
      Flavor.staging => IntegrityPolicy.warn,
      Flavor.prod => IntegrityPolicy.blockApp,
    };
  }
}
