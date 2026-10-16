part of 'host_login_bloc.dart';

abstract class HostLoginEvent {}

final class HostLoginInitialEvent extends HostLoginEvent {}

final class LoginHostEvent extends HostLoginEvent {
  final HostLoginEntity hostData;
  LoginHostEvent({required this.hostData});
}
