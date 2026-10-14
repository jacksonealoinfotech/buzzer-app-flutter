part of 'game_details_bloc.dart';

class GameDetailsState {
  final bool isLoading;

  const GameDetailsState({
    this.isLoading = false,
  });

  GameDetailsState copyWith({
    bool? isLoading,
  }) {
    return GameDetailsState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}