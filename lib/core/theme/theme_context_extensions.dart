import 'package:flutter/material.dart';
import 'package:buzzer_app/core/theme/theme_extensions.dart';

/// Ergonomic theme access extensions on [BuildContext].
extension ThemeContextExtension on BuildContext {
  /// Active [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Active Material 3 [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Active [TextTheme].
  TextTheme get text => Theme.of(this).textTheme;

  /// Whether current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Semantic status colors (Success, Warning, Info).
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;

  /// Brand gradient presets.
  AppGradients get gradients =>
      Theme.of(this).extension<AppGradients>() ?? AppGradients.light;

  /// Elevation shadow presets.
  AppShadows get shadows =>
      Theme.of(this).extension<AppShadows>() ?? AppShadows.light;
}
