import 'package:flutter_bloc/flutter_bloc.dart';
part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc
    extends Bloc<SignupEvent,
        SignupState> {

  SignupBloc()
      : super(
          const SignupState(),
        ) {

    on<SignupInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    SignupInitialEvent event,
    Emitter<SignupState> emit,
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