import 'package:buzzer_app/features/hostFlow/host_login/data/model/host_login_model.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/service/host_login_service.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/entitiy/host_login_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/repo/host_login_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HostLoginRepo)
class HostLoginRepoImple extends HostLoginRepo {
  final HostLoginService service;
  HostLoginRepoImple({required this.service});
  @override
  Future<Map<String, dynamic>> login(HostLoginEntity hostData) async =>
      await service.login(
        HostLoginModel(email: hostData.email, password: hostData.password),
      );
}
