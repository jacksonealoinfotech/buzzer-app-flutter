import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:buzzer_app/core/error/app_exception.dart';

/// Pre-flight interceptor verifying device network interface is active before firing HTTP calls.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor({required Connectivity connectivity})
    : _connectivity = connectivity;

  final Connectivity _connectivity;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOffline =
        connectivityResult.contains(ConnectivityResult.none) ||
        connectivityResult.isEmpty;

    if (isOffline) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const NetworkException(
            message: 'No internet connection available.',
          ),
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }

    handler.next(options);
  }
}
