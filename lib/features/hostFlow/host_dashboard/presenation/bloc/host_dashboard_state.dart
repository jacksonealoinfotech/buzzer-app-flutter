part of 'host_dashboard_bloc.dart';

class HostDashboardState {
  final bool isLoading;

  const HostDashboardState({
    this.isLoading = false,
  });

  HostDashboardState copyWith({
    bool? isLoading,
  }) {
    return HostDashboardState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}