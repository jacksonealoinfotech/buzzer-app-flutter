import 'package:flutter_bloc/flutter_bloc.dart';
part 'selection_event.dart';
part 'selection_state.dart';

class SelectionBloc
    extends Bloc<SelectionEvent,
        SelectionState> {

  SelectionBloc()
      : super(
          const SelectionState(),
        ) {

    on<SelectionInitialEvent>(
      _onInitial,
    );
  }

  Future<void> _onInitial(
    SelectionInitialEvent event,
    Emitter<SelectionState> emit,
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