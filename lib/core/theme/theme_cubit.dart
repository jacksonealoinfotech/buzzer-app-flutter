import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages application theme mode with automatic persistent hydration.
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// Sets the theme explicitly to light mode.
  void setLight() => emit(ThemeMode.light);

  /// Sets the theme explicitly to dark mode.
  void setDark() => emit(ThemeMode.dark);

  /// Reverts theme mode to match system preferences.
  void setSystem() => emit(ThemeMode.system);

  /// Cycles through System -> Light -> Dark modes.
  void toggleTheme() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    emit(next);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final value = json['theme_mode'] as String?;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {
      'theme_mode': switch (state) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    };
  }
}
