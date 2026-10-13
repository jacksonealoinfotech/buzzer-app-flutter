// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Clean Base';

  @override
  String get homeTitle => 'Clean Architecture Showcase';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get errorGeneric => 'An unexpected error occurred. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection detected. Please check your network.';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorUnauthorized =>
      'Session expired or unauthorized. Please sign in again.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get securityStatus => 'Security & Architecture Status';

  @override
  String get securityPassed => 'All Core Checks Passed';

  @override
  String get demoFetchSuccess =>
      'Data fetched successfully from clean architecture pipeline!';

  @override
  String get offlineBannerMessage =>
      'You are currently offline. Cached data may be shown.';
}
