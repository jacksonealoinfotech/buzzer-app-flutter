part of 'create_game_bloc.dart';

class CreateGameState {
  final bool isLoading;

  const CreateGameState({
    this.isLoading = false,
  });

  CreateGameState copyWith({
    bool? isLoading,
  }) {
    return CreateGameState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}