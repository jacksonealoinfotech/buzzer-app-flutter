import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/di/injection.dart';
import 'package:buzzer_app/core/localization/generated/app_localizations.dart';
import 'package:buzzer_app/core/localization/locale_cubit.dart';
import 'package:buzzer_app/core/router/app_router.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';
import 'package:buzzer_app/core/security/secure_screen.dart';
import 'package:buzzer_app/core/security/session_cubit.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/services/analytics/analytics_service.dart';
import 'package:buzzer_app/core/services/connectivity/connectivity_cubit.dart';
import 'package:buzzer_app/core/services/connectivity/offline_banner.dart';
import 'package:buzzer_app/core/theme/app_theme.dart';
import 'package:buzzer_app/core/widgets/feedback/messenger_service.dart';

/// Root application widget configuring global providers, router, theme, and localization.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      tokenManager: getIt<TokenManager>(),
      logger: getIt<RedactingLogger>(),
      analytics: getIt<AnalyticsService>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(connectivity: getIt<Connectivity>()),
        ),
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(tokenManager: getIt<TokenManager>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleCubit>().state;

          return MaterialApp.router(
            title: 'Flutter Clean Base',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: MessengerService.scaffoldMessengerKey,
            routerConfig: _router,

            // Theme Configuration
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,

            // Localization Configuration
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,

            // Global Decorators (Offline Banner & App-Switcher Privacy Screen)
            builder: (context, child) {
              return SecureScreen(
                child: OfflineBanner(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}
