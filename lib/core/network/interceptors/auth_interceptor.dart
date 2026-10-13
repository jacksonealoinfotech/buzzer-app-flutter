import 'dart:async';

import 'package:dio/dio.dart';
import 'package:buzzer_app/core/constants/api_endpoints.dart';
import 'package:buzzer_app/core/security/token_manager.dart';

/// Interceptor managing OAuth2 bearer token injection and single-flight refresh synchronization.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenManager tokenManager,
    required Dio dio,
    required Future<void> Function() onForceLogout,
  }) : _tokenManager = tokenManager,
       _dio = dio,
       _onForceLogout = onForceLogout;

  final TokenManager _tokenManager;
  final Dio _dio;
  final Future<void> Function() _onForceLogout;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection on public authentication endpoints
    final isAuthEndpoint =
        options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.refreshToken);

    if (!isAuthEndpoint) {
      final accessToken = _tokenManager.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Intercept HTTP 401 Unauthorized errors (excluding auth endpoints themselves)
    final isAuthEndpoint =
        requestOptions.path.contains(ApiEndpoints.login) ||
        requestOptions.path.contains(ApiEndpoints.refreshToken);

    if (response?.statusCode == 401 && !isAuthEndpoint) {
      try {
        // Coordinate single-flight refresh
        final newAccessToken = await _tokenManager.singleFlightRefresh(
          refreshCall: (refreshToken) async {
            // Create a clean Dio instance to avoid interceptor recursion
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: requestOptions.baseUrl,
                headers: {'Content-Type': 'application/json'},
              ),
            );

            final res = await refreshDio.post<Map<String, dynamic>>(
              ApiEndpoints.refreshToken,
              data: {'refresh_token': refreshToken},
            );

            final data = res.data ?? <String, dynamic>{};
            final newAccess = data['access_token'] as String? ?? '';
            final newRefresh = data['refresh_token'] as String?;
            return (newAccess, newRefresh);
          },
          onRefreshFailed: () async {
            await _onForceLogout();
          },
        );

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Retry original request with freshly acquired token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retriedResponse = await _dio.fetch<dynamic>(requestOptions);
          return handler.resolve(retriedResponse);
        }
      } catch (refreshError) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
