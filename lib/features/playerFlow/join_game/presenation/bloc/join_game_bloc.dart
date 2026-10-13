import 'package:flutter_bloc/flutter_bloc.dart';
part 'join_game_event.dart';
part 'join_game_state.dart';

class JoinGameBloc
    extends Bloc<JoinGameEvent,
        JoinGameState> {

  JoinGameBloc()
      : super(
          const JoinGameState(),
        ) {

    on<JoinGameInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    JoinGameInitialEvent event,
    Emitter<JoinGameState> emit,
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