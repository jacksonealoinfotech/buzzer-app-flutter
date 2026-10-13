part of 'game_lobby_bloc.dart';

class GameLobbyState {
  final bool isLoading;

  const GameLobbyState({
    this.isLoading = false,
  });

  GameLobbyState copyWith({
    bool? isLoading,
  }) {
    return GameLobbyState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}