part of 'host_signup_bloc.dart';

abstract class HostSignupEvent {}

final class SignupHostEvent extends HostSignupEvent {
  final HostSignupEntity userData;
  SignupHostEvent({required this.userData});
}

final class SignupResetEvent extends HostSignupEvent {}
