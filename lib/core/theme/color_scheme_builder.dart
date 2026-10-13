import 'package:flutter/material.dart';
import 'package:buzzer_app/core/theme/app_colors.dart';

/// Builds complete, balanced Material 3 [ColorScheme] instances for light and dark themes.
abstract final class ColorSchemeBuilder {
  /// Builds complete light Material 3 [ColorScheme].
  static ColorScheme buildLight() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.lightTertiary,
      onTertiary: AppColors.lightOnTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.lightSurfaceBright,
      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }

  /// Builds complete dark Material 3 [ColorScheme].
  static ColorScheme buildDark() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkOnSecondaryContainer,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnTertiary,
      tertiaryContainer: AppColors.darkTertiaryContainer,
      onTertiaryContainer: AppColors.darkOnTertiaryContainer,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceDim: AppColors.darkSurfaceDim,
      surfaceBright: AppColors.darkSurfaceBright,
      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }
}
