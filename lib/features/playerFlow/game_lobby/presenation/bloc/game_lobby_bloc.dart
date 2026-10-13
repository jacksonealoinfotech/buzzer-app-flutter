import 'package:flutter_bloc/flutter_bloc.dart';
part 'game_lobby_event.dart';
part 'game_lobby_state.dart';

class GameLobbyBloc
    extends Bloc<GameLobbyEvent,
        GameLobbyState> {

  GameLobbyBloc()
      : super(
          const GameLobbyState(),
        ) {

    on<GameLobbyInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    GameLobbyInitialEvent event,
    Emitter<GameLobbyState> emit,
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