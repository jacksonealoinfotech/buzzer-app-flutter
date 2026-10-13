import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages application active locale with persistent state hydration.
class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  /// Supported locales list.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  /// Changes active locale.
  void setLocale(Locale locale) => emit(locale);

  /// Toggles between English and Spanish.
  void toggleLocale() {
    emit(state.languageCode == 'en' ? const Locale('es') : const Locale('en'));
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final languageCode = json['language_code'] as String?;
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return const Locale('en');
  }

  @override
  Map<String, dynamic>? toJson(Locale state) {
    return {'language_code': state.languageCode};
  }
}
