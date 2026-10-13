import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/responsive/app_spacing.dart';

/// Standardized [EdgeInsets] padding presets.
abstract final class AppInsets {
  static const EdgeInsets zero = EdgeInsets.zero;

  // All Sides
  static const EdgeInsets allXs = EdgeInsets.all(AppSpacing.xs);
  static const EdgeInsets allSm = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets allXl = EdgeInsets.all(AppSpacing.xl);

  // Horizontal
  static const EdgeInsets hXs = EdgeInsets.symmetric(horizontal: AppSpacing.xs);
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

  // Vertical
  static const EdgeInsets vXs = EdgeInsets.symmetric(vertical: AppSpacing.xs);
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: AppSpacing.md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: AppSpacing.lg);

  // Screen Padding Presets
  static const EdgeInsets screenMobile = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );
  static const EdgeInsets screenTablet = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.lg,
  );
  static const EdgeInsets screenDesktop = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.lg,
  );
}
