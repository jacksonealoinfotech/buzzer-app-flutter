import 'package:buzzer_app/core/network/dio_client.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/model/host_login_model.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/service/host_login_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HostLoginService)
class HostLoginServiceImple extends HostLoginService {
  final DioClient dioClient;
  HostLoginServiceImple({required this.dioClient});
  @override
  Future<void> login(HostLoginModel hostData) async {
    await dioClient.post<Map<String, dynamic>>('/register/host');
  }
}
