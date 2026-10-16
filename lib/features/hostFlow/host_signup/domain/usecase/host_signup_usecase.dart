import 'package:buzzer_app/features/hostFlow/host_signup/domain/entitiy/host_signup_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/domain/repo/host_signup_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HostSignupUsecase {
  final HostSignupRepo repo;
  HostSignupUsecase({required this.repo});

  Future<Map<String, dynamic>> call(HostSignupEntity userData) async =>
      await repo.signup(userData);
}
