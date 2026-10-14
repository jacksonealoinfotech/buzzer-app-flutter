import 'package:flutter_bloc/flutter_bloc.dart';
part 'host_login_event.dart';
part 'host_login_state.dart';

class HostLoginBloc
    extends Bloc<HostLoginEvent,
        HostLoginState> {

  HostLoginBloc()
      : super(
          const HostLoginState(),
        ) {

    on<HostLoginInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    HostLoginInitialEvent event,
    Emitter<HostLoginState> emit,
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