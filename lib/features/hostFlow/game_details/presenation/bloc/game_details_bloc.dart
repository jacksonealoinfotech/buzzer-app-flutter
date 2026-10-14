import 'package:flutter_bloc/flutter_bloc.dart';
part 'game_details_event.dart';
part 'game_details_state.dart';

class GameDetailsBloc
    extends Bloc<GameDetailsEvent,
        GameDetailsState> {

  GameDetailsBloc()
      : super(
          const GameDetailsState(),
        ) {

    on<GameDetailsInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    GameDetailsInitialEvent event,
    Emitter<GameDetailsState> emit,
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