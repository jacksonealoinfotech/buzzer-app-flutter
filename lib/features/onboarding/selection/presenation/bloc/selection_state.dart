part of 'selection_bloc.dart';

class SelectionState {
  final bool isLoading;

  const SelectionState({
    this.isLoading = false,
  });

  SelectionState copyWith({
    bool? isLoading,
  }) {
    return SelectionState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}