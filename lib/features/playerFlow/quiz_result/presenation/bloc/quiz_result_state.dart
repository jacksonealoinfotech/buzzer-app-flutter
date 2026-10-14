part of 'quiz_result_bloc.dart';

class QuizResultState {
  final bool isLoading;

  const QuizResultState({
    this.isLoading = false,
  });

  QuizResultState copyWith({
    bool? isLoading,
  }) {
    return QuizResultState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}