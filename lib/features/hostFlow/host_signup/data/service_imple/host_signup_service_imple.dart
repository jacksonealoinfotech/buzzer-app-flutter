import 'package:buzzer_app/core/constants/api_endpoints.dart';
import 'package:buzzer_app/core/network/dio_client.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/data/model/host_signup_model.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/data/service/host_signup_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HostSignupService)
class HostSignupServiceImple extends HostSignupService {
  final DioClient dioClient;
  HostSignupServiceImple({required this.dioClient});
  @override
  Future<Map<String, dynamic>> signUp(HostSignupModel userData) async =>
      await dioClient.post<Map<String, dynamic>>(
        ApiEndpoints.registerHost,
        data: userData.toJson(),
      );
}
