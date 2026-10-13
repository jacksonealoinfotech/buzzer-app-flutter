import 'package:flutter/foundation.dart';

// TODO: Uncomment when `firebase_analytics` package is enabled in pubspec.yaml:
// import 'package:firebase_analytics/firebase_analytics.dart';

/// Contract for event tracking, funnel telemetry, and user properties.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty({required String name, required String value});
  Future<void> logScreenView({required String screenName});
}

/// Production implementation of [AnalyticsService].
class DefaultAnalyticsService implements AnalyticsService {
  // TODO: Uncomment when `firebase_analytics` is enabled:
  // final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Event: $name, Params: $parameters');
    }
    // TODO: Uncomment:
    // await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserId(String? userId) async {
    // TODO: Uncomment:
    // await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    // TODO: Uncomment:
    // await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] Screen: $screenName');
    }
    // TODO: Uncomment:
    // await _analytics.logScreenView(screenName: screenName);
  }
}
