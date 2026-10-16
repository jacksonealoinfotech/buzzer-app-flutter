import 'package:buzzer_app/features/hostFlow/host_signup/data/model/host_signup_model.dart';

abstract class HostSignupService {
  Future<Map<String, dynamic>> signUp(HostSignupModel userData);
}
