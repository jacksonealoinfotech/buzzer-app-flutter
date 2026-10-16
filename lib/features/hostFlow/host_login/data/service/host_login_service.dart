import 'package:buzzer_app/features/hostFlow/host_login/data/model/host_login_model.dart';

abstract class HostLoginService {
  Future<void> login(HostLoginModel hostData);
}
