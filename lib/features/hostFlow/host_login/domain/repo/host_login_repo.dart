import 'package:buzzer_app/features/hostFlow/host_login/domain/entitiy/host_login_entity.dart';

abstract class HostLoginRepo {
  Future<Map<String, dynamic>> login(HostLoginEntity hostData);
}
