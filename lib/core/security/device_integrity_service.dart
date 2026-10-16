import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:buzzer_app/core/config/flavor.dart';
import 'package:freerasp/freerasp.dart';

enum IntegrityPolicy { allow, warn, blockSensitiveFeatures, blockApp }

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

abstract interface class DeviceIntegrityService {
  Future<IntegrityReport> evaluateIntegrity();

  bool shouldBlockExecution(IntegrityReport report, Flavor flavor);
}

final class DefaultDeviceIntegrityService implements DeviceIntegrityService {
  // TODO: Uncomment when `freerasp` package is added:

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
