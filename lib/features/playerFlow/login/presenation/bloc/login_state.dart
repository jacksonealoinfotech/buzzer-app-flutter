part of 'login_bloc.dart';

class LoginState {
  final bool isLoading;

  const LoginState({
    this.isLoading = false,
  });

  LoginState copyWith({
    bool? isLoading,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}