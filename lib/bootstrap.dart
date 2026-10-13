import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:buzzer_app/core/config/env.dart';
import 'package:buzzer_app/core/config/flavor.dart';
import 'package:buzzer_app/core/di/injection.dart';
import 'package:buzzer_app/core/error/global_error_handler.dart';
import 'package:buzzer_app/core/notifications/notification_service.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/utils/app_bloc_observer.dart';

/// Bootstraps core services, DI, hydration, system UI, and launches the app inside [runZonedGuarded].
Future<void> bootstrap({
  required Flavor flavor,
  required Widget Function() builder,
}) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Initialize environment & active flavor
      AppEnv.initialize(appFlavor: flavor);

      // 2. Initialize HydratedBloc storage
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(
                (await getApplicationDocumentsDirectory()).path,
              ),
      );

      // 3. Configure Dependency Injection
      await configureDependencies(flavor.name);

      // 4. Initialize TokenManager (handles iOS keychain purge on fresh install)
      await getIt<TokenManager>().initialize();

      // 5. Initialize Notification Service facade
      await getIt<NotificationService>().initialize();

      // 6. Attach Global Error Handlers (Flutter, PlatformDispatcher, Isolates)
      GlobalErrorHandler.initialize(
        talker: getIt<RedactingLogger>().talkerInstance,
      );

      // 7. Attach Global Bloc Observer
      Bloc.observer = AppBlocObserver(logger: getIt<RedactingLogger>());

      // 8. Configure edge-to-edge system UI and device orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Material 3 edge-to-edge styling
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      runApp(builder());
    },
    (error, stackTrace) {
      if (getIt.isRegistered<RedactingLogger>()) {
        getIt<RedactingLogger>().critical(
          'Uncaught Zone Error',
          error,
          stackTrace,
        );
      } else {
        debugPrint('Uncaught Zone Error before DI init: $error\n$stackTrace');
      }
    },
  );
}
