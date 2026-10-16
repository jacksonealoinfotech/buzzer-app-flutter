import 'package:buzzer_app/features/hostFlow/host_login/data/repoImple/host_login_repo_imple.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/service/host_login_service.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/service_imple/host_login_service_imple.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/repo/host_login_repo.dart';
import 'package:buzzer_app/features/hostFlow/host_login/domain/usecase/host_login_usecase.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/bloc/host_login_bloc.dart';
import 'package:get_it/get_it.dart';

void hostLoginDi(GetIt sl) {
  sl.registerLazySingleton<HostLoginService>(
    () => HostLoginServiceImple(dioClient: sl()),
  );
  sl.registerLazySingleton<HostLoginRepo>(
    () => HostLoginRepoImple(service: sl()),
  );
  sl.registerLazySingleton<HostLoginUsecase>(
    () => HostLoginUsecase(repo: sl()),
  );
  sl.registerFactory<HostLoginBloc>(
    () => HostLoginBloc(hostLoginUsecase: sl()),
  );
}
