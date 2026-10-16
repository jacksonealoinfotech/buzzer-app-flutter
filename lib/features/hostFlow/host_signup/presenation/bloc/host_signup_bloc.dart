import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/utils/enum.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/domain/entitiy/host_signup_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/domain/usecase/host_signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
part 'host_signup_event.dart';
part 'host_signup_state.dart';

@injectable
class HostSignupBloc extends Bloc<HostSignupEvent, HostSignupState> {
  final HostSignupUsecase hostSignupUsecase;
  final TokenManager tokenManager;
  HostSignupBloc({required this.hostSignupUsecase, required this.tokenManager})
    : super(const HostSignupState()) {
    on<SignupResetEvent>(_reset);
    on<SignupHostEvent>(_signup);
  }
  Future<void> _reset(
    SignupResetEvent event,
    Emitter<HostSignupState> emit,
  ) async {
    emit(state.copyWith(errorMsg: null, status: RequestStatus.initial));
  }

  Future<void> _signup(
    SignupHostEvent event,
    Emitter<HostSignupState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final result = await hostSignupUsecase(event.userData);
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
