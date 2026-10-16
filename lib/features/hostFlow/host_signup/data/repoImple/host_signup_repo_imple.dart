import 'package:buzzer_app/features/hostFlow/host_signup/data/model/host_signup_model.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/data/service/host_signup_service.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/domain/entitiy/host_signup_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/domain/repo/host_signup_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HostSignupRepo)
class HostSignupRepoImple extends HostSignupRepo {
  final HostSignupService hostSignupService;
  HostSignupRepoImple({required this.hostSignupService});
  @override
  Future<Map<String, dynamic>> signup(HostSignupEntity userData) async =>
      await hostSignupService.signUp(
        HostSignupModel(
          email: userData.email,
          name: userData.name,
          password: userData.password,
        ),
      );
}
