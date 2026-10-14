part of 'host_signup_bloc.dart';

class HostSignupState {
  final bool isLoading;

  const HostSignupState({
    this.isLoading = false,
  });

  HostSignupState copyWith({
    bool? isLoading,
  }) {
    return HostSignupState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}