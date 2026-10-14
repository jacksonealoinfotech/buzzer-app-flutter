import 'package:flutter_bloc/flutter_bloc.dart';
part 'quiz_question_event.dart';
part 'quiz_question_state.dart';

class QuizQuestionBloc
    extends Bloc<QuizQuestionEvent,
        QuizQuestionState> {

  QuizQuestionBloc()
      : super(
          const QuizQuestionState(),
        ) {

    on<QuizQuestionInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    QuizQuestionInitialEvent event,
    Emitter<QuizQuestionState> emit,
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