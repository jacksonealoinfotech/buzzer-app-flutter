import 'package:flutter_bloc/flutter_bloc.dart';
part 'create_game_event.dart';
part 'create_game_state.dart';

class CreateGameBloc
    extends Bloc<CreateGameEvent,
        CreateGameState> {

  CreateGameBloc()
      : super(
          const CreateGameState(),
        ) {

    on<CreateGameInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    CreateGameInitialEvent event,
    Emitter<CreateGameState> emit,
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