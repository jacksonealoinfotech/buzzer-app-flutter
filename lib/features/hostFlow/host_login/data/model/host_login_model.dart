import 'package:buzzer_app/features/hostFlow/host_login/domain/entitiy/host_login_entity.dart';

class HostLoginModel extends HostLoginEntity {
  new({required super.email, required super.password});
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': 'host',
  };
}
