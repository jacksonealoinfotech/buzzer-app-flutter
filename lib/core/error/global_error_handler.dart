import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// Centralized global error capture and crash reporting handler.
///
/// Attaches listeners to:
/// - [FlutterError.onError] for framework widget errors
/// - [PlatformDispatcher.instance.onError] for asynchronous platform errors
/// - [Isolate.current.addErrorListener] for background isolate errors
/// - Hooks for Firebase Crashlytics & Sentry (commented out)
abstract final class GlobalErrorHandler {
  static Talker? _talker;

  /// Initializes all root error listeners.
  static void initialize({Talker? talker}) {
    _talker = talker;

    // 1. Flutter framework layout & rendering errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _talker?.error(
        'FlutterError caught by GlobalErrorHandler',
        details.exception,
        details.stack,
      );

      // In debug mode, print standard framework dump
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      _forwardToCrashReporter(details.exception, details.stack);
    };

    // 2. Uncaught asynchronous errors outside widget lifecycle
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _talker?.critical(
        'PlatformDispatcher error caught by GlobalErrorHandler',
        error,
        stack,
      );

      _forwardToCrashReporter(error, stack);
      return true; // Marked as handled
    };

    // 3. Root isolate uncaught errors
    final isolateReceivePort = ReceivePort();
    Isolate.current.addErrorListener(isolateReceivePort.sendPort);
    isolateReceivePort.listen((dynamic errorAndStack) {
      if (errorAndStack is List && errorAndStack.length >= 2) {
        final error = errorAndStack[0] as Object;
        final stack = StackTrace.fromString(errorAndStack[1].toString());
        _talker?.critical('Isolate uncaught error', error, stack);
        _forwardToCrashReporter(error, stack);
      }
    });
  }

  /// Forwards fatal and non-fatal exceptions to external crash reporting telemetry.
  static void _forwardToCrashReporter(Object error, StackTrace? stack) {
    // In debug mode, skip remote reporting
    if (kDebugMode) return;

    // Scrub potential PII from error messages before sending
    // ignore: unused_local_variable
    final sanitizedMessage = _scrubSensitiveInformation(error.toString());

    // FirebaseCrashlytics.instance.recordError(
    //   sanitizedMessage,
    //   stack,
    //   fatal: true,
    // );

    // Sentry.captureException(
    //   sanitizedMessage,
    //   stackTrace: stack,
    // );
  }

  /// Removes tokens, email addresses, and authorization headers from error logs.
  static String _scrubSensitiveInformation(String text) {
    return text
        .replaceAll(
          RegExp(r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*', caseSensitive: false),
          'Bearer [REDACTED]',
        )
        .replaceAll(
          RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
          '[REDACTED_EMAIL]',
        )
        .replaceAll(RegExp(r'\b(?:\d[ -]*?){13,16}\b'), '[REDACTED_CARD]');
  }
}
