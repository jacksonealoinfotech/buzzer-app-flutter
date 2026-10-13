// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flutter Clean Base';

  @override
  String get homeTitle => 'Demostración de Clean Architecture';

  @override
  String get themeMode => 'Modo de tema';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get errorGeneric =>
      'Ocurrió un error inesperado. Por favor, inténtelo de nuevo.';

  @override
  String get errorNetwork =>
      'No se detectó conexión a internet. Verifique su red.';

  @override
  String get errorTimeout =>
      'La solicitud caducó. Por favor, inténtelo de nuevo.';

  @override
  String get errorUnauthorized =>
      'Sesión caducada o no autorizada. Inicie sesión nuevamente.';

  @override
  String get errorNotFound => 'No se encontró el recurso solicitado.';

  @override
  String get securityStatus => 'Estado de Seguridad y Arquitectura';

  @override
  String get securityPassed => 'Todas las comprobaciones superadas';

  @override
  String get demoFetchSuccess =>
      '¡Datos recuperados con éxito a través del flujo de arquitectura limpia!';

  @override
  String get offlineBannerMessage =>
      'Estás desconectado. Se pueden mostrar datos almacenados en caché.';
}
