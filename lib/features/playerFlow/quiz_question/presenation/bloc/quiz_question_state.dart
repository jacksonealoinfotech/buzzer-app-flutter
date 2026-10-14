part of 'quiz_question_bloc.dart';

class QuizQuestionState {
  final bool isLoading;

  const QuizQuestionState({
    this.isLoading = false,
  });

  QuizQuestionState copyWith({
    bool? isLoading,
  }) {
    return QuizQuestionState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}