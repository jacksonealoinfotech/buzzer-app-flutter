import 'package:flutter/material.dart';

/// Single source of truth for raw hex color palettes.
abstract final class AppColors {
  // Brand Core
  static const Color primarySeed = Color(0xFF3730A3);
  static const Color secondarySeed = Color(0xFF3984FF);
  static const Color tertiarySeed = Color(0xFF9461FF);

  // ---------------------------------------------------------------------------
  // LIGHT PALETTE
  // ---------------------------------------------------------------------------
  static const Color lightPrimary = Color(0xFF3730A3);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFE0E7FF);
  static const Color lightOnPrimaryContainer = Color(0xFF172554);

  static const Color lightSecondary = Color(0xFF3984FF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFDCEAFF);
  static const Color lightOnSecondaryContainer = Color(0xFF172554);

  static const Color lightTertiary = Color(0xFF7C3AED);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFEDE4FF);
  static const Color lightOnTertiaryContainer = Color(0xFF3B0764);

  static const Color lightSurface = Color(0xFFF2F7FF);
  static const Color lightOnSurface = Color(0xFF172554);
  static const Color lightSurfaceDim = Color(0xFFE2EAF7);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);

  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF8FAFF);
  static const Color lightSurfaceContainer = Color(0xFFEDF3FF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE6EEFF);
  static const Color lightSurfaceContainerHighest = Color(0xFFDCE6FA);

  static const Color lightOutline = Color(0xFF7B8BA8);
  static const Color lightOutlineVariant = Color(0xFFD1DCF0);

  // ---------------------------------------------------------------------------
  // DARK PALETTE
  // ---------------------------------------------------------------------------
  static const Color darkPrimary = Color(0xFFA5B4FC);
  static const Color darkOnPrimary = Color(0xFF1E1B4B);
  static const Color darkPrimaryContainer = Color(0xFF312E81);
  static const Color darkOnPrimaryContainer = Color(0xFFE0E7FF);

  static const Color darkSecondary = Color(0xFF80B5FF);
  static const Color darkOnSecondary = Color(0xFF002B60);
  static const Color darkSecondaryContainer = Color(0xFF174A91);
  static const Color darkOnSecondaryContainer = Color(0xFFDCEAFF);

  static const Color darkTertiary = Color(0xFFC4A5FF);
  static const Color darkOnTertiary = Color(0xFF35105F);
  static const Color darkTertiaryContainer = Color(0xFF54249A);
  static const Color darkOnTertiaryContainer = Color(0xFFEDE4FF);

  static const Color darkSurface = Color(0xFF0B1024);
  static const Color darkOnSurface = Color(0xFFE8EEFF);
  static const Color darkSurfaceDim = Color(0xFF080D1C);
  static const Color darkSurfaceBright = Color(0xFF252D49);

  static const Color darkSurfaceContainerLowest = Color(0xFF070B18);
  static const Color darkSurfaceContainerLow = Color(0xFF10172D);
  static const Color darkSurfaceContainer = Color(0xFF161F3B);
  static const Color darkSurfaceContainerHigh = Color(0xFF202B4A);
  static const Color darkSurfaceContainerHighest = Color(0xFF2B3657);

  static const Color darkOutline = Color(0xFF8C9CC2);
  static const Color darkOutlineVariant = Color(0xFF3A4668);

  // ---------------------------------------------------------------------------
  // SEMANTIC & STATUS COLORS
  // ---------------------------------------------------------------------------
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFE4E6);
  static const Color onErrorContainer = Color(0xFF881337);

  static const Color darkError = Color(0xFFFF8A8A);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFF422006);
  static const Color info = Color(0xFF3984FF);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Common Utilities
  static const Color shimmerBase = Color(0xFFE2EAF7);
  static const Color shimmerHighlight = Color(0xFFF8FAFF);
  static const Color shimmerDarkBase = Color(0xFF202B4A);
  static const Color shimmerDarkHighlight = Color(0xFF354264);
}
