part of 'host_login_bloc.dart';

class HostLoginState {
  final RequestStatus status;
  final String? errorMsg;
  const HostLoginState({this.status = RequestStatus.initial, this.errorMsg});

  HostLoginState copyWith({RequestStatus? status, String? errorMsg}) {
    return HostLoginState(
      status: status ?? this.status,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}
