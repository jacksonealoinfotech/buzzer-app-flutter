import 'package:buzzer_app/features/hostFlow/host_signup/domain/entitiy/host_signup_entity.dart';

class HostSignupModel extends HostSignupEntity {
  new({required super.email, required super.name, required super.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'full_name': name,
  };
}
