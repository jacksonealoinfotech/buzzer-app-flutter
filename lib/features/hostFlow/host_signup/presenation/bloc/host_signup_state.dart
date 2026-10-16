part of 'host_signup_bloc.dart';

class HostSignupState {
  final RequestStatus status;
  final String? errorMsg;

  const HostSignupState({this.status = RequestStatus.initial, this.errorMsg});

  HostSignupState copyWith({RequestStatus? status, String? errorMsg}) {
    return HostSignupState(
      status: status ?? this.status,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
