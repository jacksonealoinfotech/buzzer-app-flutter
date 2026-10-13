import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/responsive/breakpoints.dart';

/// Performance-optimized responsive helpers on [BuildContext] using targeted
/// `MediaQuery.sizeOf`, `paddingOf`, and `viewInsetsOf` to eliminate unnecessary rebuilds.
extension ResponsiveContextExtension on BuildContext {
  /// Window size class (compact, medium, expanded).
  WindowSizeClass get windowSizeClass => Breakpoints.fromContext(this);

  /// Whether active display is compact (< 600dp).
  bool get isCompact => windowSizeClass.isCompact;

  /// Whether active display is medium (600dp - 840dp).
  bool get isMedium => windowSizeClass.isMedium;

  /// Whether active display is expanded (> 840dp).
  bool get isExpanded => windowSizeClass.isExpanded;

  /// Screen width in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// SafeArea padding.
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  /// Keyboard insets (height when on-screen keyboard is visible).
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Whether software keyboard is actively visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Whether device is in portrait orientation.
  bool get isPortrait => screenHeight > screenWidth;

  /// Whether device is in landscape orientation.
  bool get isLandscape => screenWidth >= screenHeight;

  /// Active text scale factor clamped within safe limits.
  double safeTextScale({double min = 0.8, double max = 1.3}) {
    final scale = MediaQuery.textScalerOf(this).scale(1);
    return scale.clamp(min, max);
  }
}
