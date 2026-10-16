import 'package:buzzer_app/features/hostFlow/host_login/domain/usecase/host_login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
part 'host_login_event.dart';
part 'host_login_state.dart';

@injectable
class HostLoginBloc extends Bloc<HostLoginEvent, HostLoginState> {
  final HostLoginUsecase hostLoginUsecase;
  HostLoginBloc({required this.hostLoginUsecase})
    : super(const HostLoginState()) {
    on<HostLoginInitialEvent>(_onInitial);
  }

  Future<void> _onInitial(
    HostLoginInitialEvent event,
    Emitter<HostLoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Add your feature logic here

    emit(state.copyWith(isLoading: false));
  }
}
