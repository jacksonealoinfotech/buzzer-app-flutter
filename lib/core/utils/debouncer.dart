import 'dart:async';

/// Debouncer delaying execution until a duration has elapsed without new calls.
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

/// Throttler ensuring an action is executed at most once per duration window.
class Throttler {
  Throttler({required this.duration});

  final Duration duration;
  DateTime? _lastExecution;

  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastExecution == null ||
        now.difference(_lastExecution!) >= duration) {
      _lastExecution = now;
      action();
    }
  }

  void reset() {
    _lastExecution = null;
  }
}

/// Standalone async retry helper executing an operation with exponential backoff.
abstract final class RetryHelper {
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 300),
    double backoffMultiplier = 2.0,
    bool Function(Object error)? retryIf,
  }) async {
    var attempt = 0;
    var currentDelay = initialDelay;

    while (true) {
      attempt++;
      try {
        return await operation();
      } catch (error) {
        final shouldRetry = retryIf == null || retryIf(error);
        if (attempt >= maxAttempts || !shouldRetry) {
          rethrow;
        }
        await Future<void>.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }
  }
}
