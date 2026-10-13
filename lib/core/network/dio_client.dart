import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:buzzer_app/core/config/env.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Production-ready wrapper around [Dio] providing type-safe HTTP primitives,
/// background isolate JSON parsing for high-throughput payloads, and cancellation tokens.
class DioClient {
  DioClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Dio get rawDio => _dio;

  /// Factory creating [DioClient] configured with flavor settings and security adapters.
  factory DioClient.create({
    required List<Interceptor> interceptors,
    HttpClientAdapter? adapter,
    String? baseUrl,
  }) {
    final effectiveBaseUrl = baseUrl ?? AppEnv.apiBaseUrl;

    final dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: Duration(seconds: AppEnv.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppEnv.receiveTimeoutSeconds),
        sendTimeout: AppDurations.connectTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }

    dio.interceptors.addAll(interceptors);
    return DioClient(dio: dio);
  }

  /// Type-safe HTTP GET
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? decoder,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parsePayload<T>(response.data, decoder);
  }

  /// Type-safe HTTP POST
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    T Function(Object? json)? decoder,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return _parsePayload<T>(response.data, decoder);
  }

  /// Type-safe HTTP PUT
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? decoder,
  }) async {
    final response = await _dio.put<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parsePayload<T>(response.data, decoder);
  }

  /// Type-safe HTTP PATCH
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? decoder,
  }) async {
    final response = await _dio.patch<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parsePayload<T>(response.data, decoder);
  }

  /// Type-safe HTTP DELETE
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Object? json)? decoder,
  }) async {
    final response = await _dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _parsePayload<T>(response.data, decoder);
  }

  /// Offloads JSON parsing to a background isolate for substantial payloads
  /// to preserve 60/120 FPS UI thread smoothness.
  Future<T> _parsePayload<T>(
    dynamic data,
    T Function(Object? json)? decoder,
  ) async {
    if (decoder == null) {
      return data as T;
    }

    // Small scalar values parsed directly on UI isolate
    if (data is num || data is bool || data is String || data == null) {
      return decoder(data);
    }

    // Offload parsing to worker isolate
    return Isolate.run<T>(() => decoder(data));
  }
}
