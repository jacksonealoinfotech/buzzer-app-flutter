import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';
import 'package:buzzer_app/core/security/session_state.dart';
import 'package:buzzer_app/core/security/token_manager.dart';

/// Manages active session lifecycle, background auto-lock, and idle timeouts.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required TokenManager tokenManager})
    : _tokenManager = tokenManager,
      super(
        tokenManager.isAuthenticated
            ? SessionActive(lastActivity: DateTime.now())
            : const SessionUnauthenticated(),
      ) {
    _authSubscription = _tokenManager.isAuthenticatedStream.listen((isAuth) {
      if (!isAuth) {
        emit(const SessionUnauthenticated());
      } else if (state is SessionUnauthenticated) {
        emit(SessionActive(lastActivity: DateTime.now()));
      }
    });
  }

  final TokenManager _tokenManager;
  StreamSubscription<bool>? _authSubscription;
  Timer? _idleTimer;

  /// Registers user interaction to refresh session idle timer.
  void recordUserActivity() {
    if (state is SessionActive) {
      emit(SessionActive(lastActivity: DateTime.now()));
      _scheduleIdleCheck();
    }
  }

  void _scheduleIdleCheck() {
    _idleTimer?.cancel();
    _idleTimer = Timer(AppDurations.sessionIdleTimeout, () {
      if (state is SessionActive) {
        emit(const SessionExpired());
      }
    });
  }

  /// Locks session when app returns from prolonged backgrounding.
  void lockSession({String reason = 'App backgrounded'}) {
    if (state is SessionActive) {
      emit(SessionLocked(reason: reason));
    }
  }

  /// Unlocks session after successful biometric or PIN verification.
  void unlockSession() {
    if (state is SessionLocked) {
      emit(SessionActive(lastActivity: DateTime.now()));
      _scheduleIdleCheck();
    }
  }

  @override
  Future<void> close() {
    _idleTimer?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
