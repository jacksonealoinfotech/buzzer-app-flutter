import 'package:flutter_bloc/flutter_bloc.dart';
part 'host_signup_event.dart';
part 'host_signup_state.dart';

class HostSignupBloc
    extends Bloc<HostSignupEvent,
        HostSignupState> {

  HostSignupBloc()
      : super(
          const HostSignupState(),
        ) {

    on<HostSignupInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    HostSignupInitialEvent event,
    Emitter<HostSignupState> emit,
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