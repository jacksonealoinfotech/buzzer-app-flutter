part of 'host_login_bloc.dart';

abstract class HostLoginEvent {}

final class LoginHostEvent extends HostLoginEvent {
  final HostLoginEntity hostData;
  LoginHostEvent({required this.hostData});
}

final class ResetHostLoginState extends HostLoginEvent {}
