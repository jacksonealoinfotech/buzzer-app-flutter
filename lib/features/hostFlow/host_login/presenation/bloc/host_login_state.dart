part of 'host_login_bloc.dart';

class HostLoginState {
  final bool isLoading;

  const HostLoginState({
    this.isLoading = false,
  });

  HostLoginState copyWith({
    bool? isLoading,
  }) {
    return HostLoginState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}