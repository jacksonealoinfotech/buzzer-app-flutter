import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';

/// HTTP logger interceptor filtering sensitive payload tokens through [RedactingLogger].
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required RedactingLogger logger}) : _logger = logger;

  final RedactingLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.info('--> HTTP ${options.method.toUpperCase()} ${options.uri}');
      if (options.data != null) {
        _logger.debug('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      _logger.info(
        '<-- HTTP ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      '<-- HTTP ERROR ${err.response?.statusCode} ${err.requestOptions.uri}',
      err.message,
    );
    handler.next(err);
  }
}
