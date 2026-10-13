part of 'join_game_bloc.dart';

class JoinGameState {
  final bool isLoading;

  const JoinGameState({
    this.isLoading = false,
  });

  JoinGameState copyWith({
    bool? isLoading,
  }) {
    return JoinGameState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}