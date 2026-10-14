import 'package:flutter_bloc/flutter_bloc.dart';
part 'host_dashboard_event.dart';
part 'host_dashboard_state.dart';

class HostDashboardBloc
    extends Bloc<HostDashboardEvent,
        HostDashboardState> {

  HostDashboardBloc()
      : super(
          const HostDashboardState(),
        ) {

    on<HostDashboardInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    HostDashboardInitialEvent event,
    Emitter<HostDashboardState> emit,
  ) async {

    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    // Add your feature logic here

    emit(
      state.copyWith(
        isLoading: false,
      ),
    );
  }
}