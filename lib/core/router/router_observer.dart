import 'package:flutter/material.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';
import 'package:buzzer_app/core/services/analytics/analytics_service.dart';

/// Navigation observer capturing route transitions for diagnostics and analytics.
class AppRouterObserver extends NavigatorObserver {
  AppRouterObserver({
    required RedactingLogger logger,
    required AnalyticsService analytics,
  }) : _logger = logger,
       _analytics = analytics;

  final RedactingLogger _logger;
  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final screenName = route.settings.name ?? route.settings.toString();
    _logger.info('[Navigation] Pushed: $screenName');
    _analytics.logScreenView(screenName: screenName);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final screenName = route.settings.name ?? route.settings.toString();
    _logger.info('[Navigation] Popped: $screenName');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final screenName =
        newRoute?.settings.name ?? newRoute?.settings.toString() ?? 'unknown';
    _logger.info('[Navigation] Replaced with: $screenName');
    _analytics.logScreenView(screenName: screenName);
  }
}
