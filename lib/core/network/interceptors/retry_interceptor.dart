import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// HTTP Retry interceptor executing exponential backoff with random jitter.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = AppDurations.retryBaseDelay,
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Random _random = Random();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final currentRetryCount =
        (requestOptions.extra['retry_count'] as int?) ?? 0;

    if (_shouldRetry(err) && currentRetryCount < maxRetries) {
      requestOptions.extra['retry_count'] = currentRetryCount + 1;

      // Exponential backoff with jitter: delay = base * 2^attempt + jitter
      final backoffFactor = pow(2, currentRetryCount).toInt();
      final jitterMs = _random.nextInt(250);
      final delay = Duration(
        milliseconds: (baseDelay.inMilliseconds * backoffFactor) + jitterMs,
      );

      await Future<void>.delayed(delay);

      try {
        final response = await _dio.fetch<dynamic>(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryException) {
        return handler.next(retryException);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    final statusCode = err.response?.statusCode;
    if (statusCode == null) return false;

    // Retry transient server errors
    return statusCode == 408 ||
        statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }
}
