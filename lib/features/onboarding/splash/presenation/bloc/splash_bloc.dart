import 'package:flutter_bloc/flutter_bloc.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc
    extends Bloc<SplashEvent,
        SplashState> {

  SplashBloc()
      : super(
          const SplashState(),
        ) {

    on<SplashInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
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