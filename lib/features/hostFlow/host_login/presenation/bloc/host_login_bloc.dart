import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/utils/enum.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/entitiy/host_login_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/usecase/host_login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
part 'host_login_event.dart';
part 'host_login_state.dart';

@injectable
class HostLoginBloc extends Bloc<HostLoginEvent, HostLoginState> {
  final HostLoginUsecase hostLoginUsecase;
  final TokenManager tokenManager;
  HostLoginBloc({required this.hostLoginUsecase, required this.tokenManager})
    : super(const HostLoginState()) {
    on<ResetHostLoginState>(_reset);
    on<LoginHostEvent>(_login);
  }
  Future<void> _reset(
    ResetHostLoginState event,
    Emitter<HostLoginState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.initial, errorMsg: null));
  }

  Future<void> _login(
    LoginHostEvent event,
    Emitter<HostLoginState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final result = await hostLoginUsecase(hostData: event.hostData);
      await tokenManager.saveTokens(
        accessToken: result['access_token'] as String,
        refreshToken: result['refresh_token'] as String,
      );
      emit(state.copyWith(status: RequestStatus.completed));
    } catch (e) {
      emit(
        state.copyWith(errorMsg: e.toString(), status: RequestStatus.failure),
      );
    }
  }
}
