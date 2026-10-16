import 'package:buzzer_app/features/hostFlow/host_login/domain/entitiy/host_login_entity.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/repo/host_login_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class HostLoginUsecase {
  final HostLoginRepo repo;
  HostLoginUsecase({required this.repo});
  Future<Map<String, dynamic>> call({
    required HostLoginEntity hostData,
  }) async => repo.login(hostData);
}
