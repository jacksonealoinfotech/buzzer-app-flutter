import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/router/app_routes.dart';
import 'package:buzzer_app/core/router/router_observer.dart';
import 'package:buzzer_app/core/router/router_refresh_stream.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/services/analytics/analytics_service.dart';
import 'package:buzzer_app/core/widgets/feedback/messenger_service.dart';
import 'package:buzzer_app/core/widgets/views/not_found_screen.dart';

/// Factory creating configured [GoRouter] with typed routes and authentication guards.
GoRouter createAppRouter({
  required TokenManager tokenManager,
  required RedactingLogger logger,
  required AnalyticsService analytics,
}) {
  return GoRouter(
    navigatorKey: MessengerService.rootNavigatorKey,
    initialLocation: '/splash',
    routes: $appRoutes,
    refreshListenable: GoRouterRefreshStream(
      tokenManager.isAuthenticatedStream,
    ),
    observers: [AppRouterObserver(logger: logger, analytics: analytics)],
    errorBuilder: (context, state) =>
        NotFoundScreen(errorMessage: state.error?.message),
    redirect: (BuildContext context, GoRouterState state) {
      // Auth Guard Redirect:
      // In this template, public demonstration routes are allowed.
      // If a route requires authentication and tokenManager.isAuthenticated is false:
      // return '/login';
      return null;
    },
  );
}
