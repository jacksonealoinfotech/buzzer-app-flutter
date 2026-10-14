import 'package:flutter_bloc/flutter_bloc.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc
    extends Bloc<SettingsEvent,
        SettingsState> {

  SettingsBloc()
      : super(
          const SettingsState(),
        ) {

    on<SettingsInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    SettingsInitialEvent event,
    Emitter<SettingsState> emit,
  ) async {

    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    // Add your feature logic here

    emit(
      state.copyWith(
        isLoading: false,
      ),
    );
  }
}