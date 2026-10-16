// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:talker/talker.dart' as _i993;

import '../../features/hostFlow/host_login/data/repoImple/host_login_repo_imple.dart'
    as _i524;
import '../../features/hostFlow/host_login/data/service/host_login_service.dart'
    as _i89;
import '../../features/hostFlow/host_login/data/service_imple/host_login_service_imple.dart'
    as _i330;
import '../../features/hostFlow/host_login/domain/repo/host_login_repo.dart'
    as _i54;
import '../../features/hostFlow/host_login/domain/usecase/host_login_usecase.dart'
    as _i412;
import '../../features/hostFlow/host_login/presenation/bloc/host_login_bloc.dart'
    as _i384;
import '../../features/hostFlow/host_signup/data/repoImple/host_signup_repo_imple.dart'
    as _i260;
import '../../features/hostFlow/host_signup/data/service/host_signup_service.dart'
    as _i9;
import '../../features/hostFlow/host_signup/data/service_imple/host_signup_service_imple.dart'
    as _i274;
import '../../features/hostFlow/host_signup/domain/repo/host_signup_repo.dart'
    as _i163;
import '../../features/hostFlow/host_signup/domain/usecase/host_signup_usecase.dart'
    as _i60;
import '../../features/hostFlow/host_signup/presenation/bloc/host_signup_bloc.dart'
    as _i551;
import '../config/remote_config_hook.dart' as _i5;
import '../database/app_database.dart' as _i982;
import '../database/daos/items_dao.dart' as _i309;
import '../network/dio_client.dart' as _i667;
import '../notifications/notification_service.dart' as _i229;
import '../security/app_lock_service.dart' as _i217;
import '../security/device_integrity_service.dart' as _i39;
import '../security/redacting_logger.dart' as _i978;
import '../security/secure_storage_service.dart' as _i812;
import '../security/security_service.dart' as _i383;
import '../security/token_manager.dart' as _i552;
import '../security/token_storage.dart' as _i77;
import '../services/analytics/analytics_service.dart' as _i554;
import '../services/crash/crash_reporting_service.dart' as _i824;
import '../services/permissions/permission_service.dart' as _i202;
import '../services/storage/local_storage_service.dart' as _i684;
import 'modules/network_module.dart' as _i851;
import 'modules/storage_module.dart' as _i148;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final storageModule = _$StorageModule();
    gh.lazySingleton<_i895.Connectivity>(() => networkModule.connectivity);
    gh.lazySingleton<_i993.Talker>(() => networkModule.talker);
    gh.lazySingleton<_i77.TokenStorage>(() => networkModule.tokenStorage);
    gh.lazySingleton<_i812.SecureStorageService>(
      () => networkModule.secureStorageService,
    );
    gh.lazySingleton<_i39.DeviceIntegrityService>(
      () => networkModule.deviceIntegrityService,
    );
    gh.lazySingleton<_i217.AppLockService>(() => networkModule.appLockService);
    gh.lazySingleton<_i5.RemoteConfigHook>(
      () => networkModule.remoteConfigHook,
    );
    gh.lazySingleton<_i202.PermissionService>(
      () => networkModule.permissionService,
    );
    gh.lazySingleton<_i554.AnalyticsService>(
      () => networkModule.analyticsService,
    );
    gh.lazySingleton<_i824.CrashReportingService>(
      () => networkModule.crashReportingService,
    );
    gh.lazySingleton<_i229.NotificationService>(
      () => networkModule.notificationService(),
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => storageModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i982.AppDatabase>(() => storageModule.appDatabase);
    gh.lazySingleton<_i552.TokenManager>(
      () => networkModule.tokenManager(
        gh<_i77.TokenStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i383.SecurityService>(
      () => networkModule.securityService(
        gh<_i552.TokenManager>(),
        gh<_i812.SecureStorageService>(),
        gh<_i982.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i978.RedactingLogger>(
      () => networkModule.redactingLogger(gh<_i993.Talker>()),
    );
    gh.lazySingleton<_i309.ItemsDao>(
      () => storageModule.itemsDao(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i684.LocalStorageService>(
      () => storageModule.localStorageService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i667.DioClient>(
      () => networkModule.dioClient(
        gh<_i895.Connectivity>(),
        gh<_i978.RedactingLogger>(),
        gh<_i552.TokenManager>(),
        gh<_i383.SecurityService>(),
      ),
    );
    gh.lazySingleton<_i9.HostSignupService>(
      () => _i274.HostSignupServiceImple(dioClient: gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i89.HostLoginService>(
      () => _i330.HostLoginServiceImple(dioClient: gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i163.HostSignupRepo>(
      () => _i260.HostSignupRepoImple(
        hostSignupService: gh<_i9.HostSignupService>(),
      ),
    );
    gh.lazySingleton<_i60.HostSignupUsecase>(
      () => _i60.HostSignupUsecase(repo: gh<_i163.HostSignupRepo>()),
    );
    gh.lazySingleton<_i54.HostLoginRepo>(
      () => _i524.HostLoginRepoImple(service: gh<_i89.HostLoginService>()),
    );
    gh.factory<_i412.HostLoginUsecase>(
      () => _i412.HostLoginUsecase(repo: gh<_i54.HostLoginRepo>()),
    );
    gh.factory<_i551.HostSignupBloc>(
      () => _i551.HostSignupBloc(
        hostSignupUsecase: gh<_i60.HostSignupUsecase>(),
        tokenManager: gh<_i552.TokenManager>(),
      ),
    );
    gh.factory<_i384.HostLoginBloc>(
      () => _i384.HostLoginBloc(
        hostLoginUsecase: gh<_i412.HostLoginUsecase>(),
        tokenManager: gh<_i552.TokenManager>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i851.NetworkModule {}

class _$StorageModule extends _i148.StorageModule {}
