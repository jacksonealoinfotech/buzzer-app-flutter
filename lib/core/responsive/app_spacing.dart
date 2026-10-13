import 'package:flutter/widgets.dart';

/// 4pt/8pt spacing scale constants.
abstract final class AppSpacing {
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Performant, const SizedBox spacing widgets.
abstract final class Gap {
  // Horizontal Gaps
  static const Widget h2 = SizedBox(width: AppSpacing.xxxs);
  static const Widget h4 = SizedBox(width: AppSpacing.xxs);
  static const Widget h8 = SizedBox(width: AppSpacing.xs);
  static const Widget h12 = SizedBox(width: AppSpacing.sm);
  static const Widget h16 = SizedBox(width: AppSpacing.md);
  static const Widget h24 = SizedBox(width: AppSpacing.lg);
  static const Widget h32 = SizedBox(width: AppSpacing.xl);
  static const Widget h48 = SizedBox(width: AppSpacing.xxl);

  // Vertical Gaps
  static const Widget v2 = SizedBox(height: AppSpacing.xxxs);
  static const Widget v4 = SizedBox(height: AppSpacing.xxs);
  static const Widget v8 = SizedBox(height: AppSpacing.xs);
  static const Widget v12 = SizedBox(height: AppSpacing.sm);
  static const Widget v16 = SizedBox(height: AppSpacing.md);
  static const Widget v24 = SizedBox(height: AppSpacing.lg);
  static const Widget v32 = SizedBox(height: AppSpacing.xl);
  static const Widget v48 = SizedBox(height: AppSpacing.xxl);

  /// Custom horizontal gap.
  static Widget customH(double width) => SizedBox(width: width);

  /// Custom vertical gap.
  static Widget customV(double height) => SizedBox(height: height);
}
