part of 'signup_bloc.dart';

class SignupState {
  final bool isLoading;

  const SignupState({
    this.isLoading = false,
  });

  SignupState copyWith({
    bool? isLoading,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}