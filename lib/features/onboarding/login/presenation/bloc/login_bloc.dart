import 'package:flutter_bloc/flutter_bloc.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc
    extends Bloc<LoginEvent,
        LoginState> {

  LoginBloc()
      : super(
          const LoginState(),
        ) {

    on<LoginInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
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