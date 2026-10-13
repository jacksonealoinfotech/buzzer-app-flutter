import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';

/// Global BlocObserver recording transitions, events, and errors through [RedactingLogger].
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required RedactingLogger logger}) : _logger = logger;

  final RedactingLogger _logger;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _logger.debug('[Bloc Created] ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.debug('[Bloc Change] ${bloc.runtimeType} -> ${change.nextState}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error('[Bloc Error] ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _logger.debug('[Bloc Closed] ${bloc.runtimeType}');
  }
}
