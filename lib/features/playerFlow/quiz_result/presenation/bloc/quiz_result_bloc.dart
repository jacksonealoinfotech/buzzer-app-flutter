import 'package:flutter_bloc/flutter_bloc.dart';
part 'quiz_result_event.dart';
part 'quiz_result_state.dart';

class QuizResultBloc
    extends Bloc<QuizResultEvent,
        QuizResultState> {

  QuizResultBloc()
      : super(
          const QuizResultState(),
        ) {

    on<QuizResultInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    QuizResultInitialEvent event,
    Emitter<QuizResultState> emit,
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