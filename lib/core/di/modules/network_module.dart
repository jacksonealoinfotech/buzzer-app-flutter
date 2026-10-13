import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:buzzer_app/core/config/env.dart';
import 'package:buzzer_app/core/config/remote_config_hook.dart';
import 'package:buzzer_app/core/database/app_database.dart';
import 'package:buzzer_app/core/network/dio_client.dart';
import 'package:buzzer_app/core/network/interceptors/auth_interceptor.dart';
import 'package:buzzer_app/core/network/interceptors/connectivity_interceptor.dart';
import 'package:buzzer_app/core/network/interceptors/logging_interceptor.dart';
import 'package:buzzer_app/core/network/interceptors/retry_interceptor.dart';
import 'package:buzzer_app/core/notifications/default_notification_service.dart';
import 'package:buzzer_app/core/notifications/firebase_messaging_service.dart';
import 'package:buzzer_app/core/notifications/local_notification_service.dart';
import 'package:buzzer_app/core/notifications/notification_service.dart';
import 'package:buzzer_app/core/security/app_lock_service.dart';
import 'package:buzzer_app/core/security/certificate_pinning_adapter.dart';
import 'package:buzzer_app/core/security/device_integrity_service.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';
import 'package:buzzer_app/core/security/secure_storage_service.dart';
import 'package:buzzer_app/core/security/secure_token_storage.dart';
import 'package:buzzer_app/core/security/security_interceptor.dart';
import 'package:buzzer_app/core/security/security_service.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/security/token_storage.dart';
import 'package:buzzer_app/core/services/analytics/analytics_service.dart';
import 'package:buzzer_app/core/services/crash/crash_reporting_service.dart';
import 'package:buzzer_app/core/services/permissions/permission_service.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  Talker get talker => Talker();

  @lazySingleton
  RedactingLogger redactingLogger(Talker talker) => RedactingLogger(talker);

  @lazySingleton
  TokenStorage get tokenStorage => SecureTokenStorage();

  @lazySingleton
  SecureStorageService get secureStorageService =>
      DefaultSecureStorageService();

  @lazySingleton
  TokenManager tokenManager(TokenStorage storage, SharedPreferences prefs) =>
      TokenManager(tokenStorage: storage, preferences: prefs);

  @lazySingleton
  SecurityService securityService(
    TokenManager tokenManager,
    SecureStorageService secureStorageService,
    AppDatabase appDatabase,
  ) => SecurityService(
    tokenManager: tokenManager,
    secureStorageService: secureStorageService,
    onDatabaseWipe: () => appDatabase.wipeAllData(),
  );

  @lazySingleton
  DeviceIntegrityService get deviceIntegrityService =>
      DefaultDeviceIntegrityService();

  @lazySingleton
  AppLockService get appLockService => DefaultAppLockService();

  @lazySingleton
  RemoteConfigHook get remoteConfigHook => DefaultRemoteConfigService();

  @lazySingleton
  PermissionService get permissionService => DefaultPermissionService();

  @lazySingleton
  AnalyticsService get analyticsService => DefaultAnalyticsService();

  @lazySingleton
  CrashReportingService get crashReportingService =>
      DefaultCrashReportingService();

  @lazySingleton
  NotificationService notificationService() {
    return DefaultNotificationService(
      localNotifications: LocalNotificationService(),
      firebaseMessaging: FirebaseMessagingService(),
    );
  }

  @lazySingleton
  DioClient dioClient(
    Connectivity connectivity,
    RedactingLogger logger,
    TokenManager tokenManager,
    SecurityService securityService,
  ) {
    // 1. Build Certificate Pinning Adapter (enforcing SPKI hashes in staging/prod)
    final pinningAdapter = createCertificatePinningAdapter(
      allowedPins: [AppEnv.primaryCertPin, AppEnv.backupCertPin],
      isEnabled: AppEnv.enableCertificatePinning,
    );

    // 2. Prepare interceptor chain
    final rawDio = Dio();
    final interceptors = <Interceptor>[
      SecurityInterceptor(),
      ConnectivityInterceptor(connectivity: connectivity),
      AuthInterceptor(
        tokenManager: tokenManager,
        dio: rawDio,
        onForceLogout: () => securityService.wipeAll(),
      ),
      LoggingInterceptor(logger: logger),
      RetryInterceptor(dio: rawDio),
    ];

    return DioClient.create(
      interceptors: interceptors,
      adapter: pinningAdapter,
    );
  }
}
