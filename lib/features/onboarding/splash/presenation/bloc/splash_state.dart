part of 'splash_bloc.dart';

class SplashState {
  final bool isLoading;

  const SplashState({
    this.isLoading = false,
  });

  SplashState copyWith({
    bool? isLoading,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}