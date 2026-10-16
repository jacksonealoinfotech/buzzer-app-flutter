import 'package:buzzer_app/features/hostFlow/host_signup/domain/entitiy/host_signup_entity.dart';

abstract class HostSignupRepo {
  Future<Map<String, dynamic>> signup(HostSignupEntity userData);
}
