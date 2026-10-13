import 'package:dio/dio.dart';
import 'package:buzzer_app/core/error/app_exception.dart';
import 'package:buzzer_app/core/error/failure.dart';

/// Centralized mapper transforming network exceptions ([DioException]), infrastructure
/// exceptions ([AppException]), and arbitrary objects into domain-level [Failure]s.
abstract final class ErrorMapper {
  /// Converts a [DioException] into an [AppException].
  static AppException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(
          message: 'Network request timed out: ${dioException.message}',
          cause: dioException,
        );

      case DioExceptionType.badCertificate:
        return SecurityException(
          message: 'SSL/TLS certificate verification failed.',
          cause: dioException,
        );

      case DioExceptionType.cancel:
        return CancelledException(
          message: 'Request was cancelled: ${dioException.message}',
          cause: dioException,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Unable to connect to server. Check network connection.',
          cause: dioException,
        );

      case DioExceptionType.badResponse:
        final response = dioException.response;
        final statusCode = response?.statusCode ?? 500;
        final responseData = response?.data;
        final serverMessage = _extractServerMessage(responseData);

        return switch (statusCode) {
          400 => ValidationException(
            message: serverMessage ?? 'Bad request. Please verify your input.',
            fieldErrors: _extractFieldErrors(responseData),
            cause: dioException,
          ),
          401 => UnauthorizedException(
            message:
                serverMessage ?? 'Authentication token is invalid or expired.',
            cause: dioException,
          ),
          403 => ForbiddenException(
            message: serverMessage ?? 'Access to this resource is forbidden.',
            cause: dioException,
          ),
          404 => NotFoundException(
            message:
                serverMessage ??
                'Requested endpoint or resource was not found.',
            cause: dioException,
          ),
          408 => TimeoutException(
            message: serverMessage ?? 'Request timed out on the server.',
            cause: dioException,
          ),
          409 => ValidationException(
            message:
                serverMessage ?? 'Conflict: resource state conflict occurred.',
            cause: dioException,
          ),
          422 => ValidationException(
            message:
                serverMessage ??
                'Unprocessable entity: semantic validation failed.',
            fieldErrors: _extractFieldErrors(responseData),
            cause: dioException,
          ),
          429 => ValidationException(
            message: serverMessage ?? 'Too many requests. Please slow down.',
            cause: dioException,
          ),
          >= 500 && < 600 => ServerException(
            message: serverMessage ?? 'Internal server error occurred.',
            statusCode: statusCode,
            cause: dioException,
          ),
          _ => ServerException(
            message: serverMessage ?? 'Unexpected HTTP status: $statusCode',
            statusCode: statusCode,
            cause: dioException,
          ),
        };

      case DioExceptionType.unknown:
        return UnknownException(
          message: dioException.message ?? 'Unknown network error occurred.',
          cause: dioException,
        );
    }
  }

  /// Maps an [AppException] to a domain [Failure].
  static Failure fromAppException(AppException exception) {
    return switch (exception) {
      NetworkException(:final message, :final code, :final cause) =>
        NetworkFailure(message: message, code: code, cause: cause),
      TimeoutException(:final message, :final code, :final cause) =>
        TimeoutFailure(message: message, code: code, cause: cause),
      UnauthorizedException(:final message, :final code, :final cause) =>
        UnauthorizedFailure(message: message, code: code, cause: cause),
      ForbiddenException(:final message, :final code, :final cause) =>
        ForbiddenFailure(message: message, code: code, cause: cause),
      NotFoundException(:final message, :final code, :final cause) =>
        NotFoundFailure(message: message, code: code, cause: cause),
      ValidationException(
        :final message,
        :final code,
        :final fieldErrors,
        :final cause,
      ) =>
        ValidationFailure(
          message: message,
          code: code,
          fieldErrors: fieldErrors,
          cause: cause,
        ),
      ServerException(
        :final message,
        :final code,
        :final statusCode,
        :final cause,
      ) =>
        ServerFailure(
          message: message,
          code: code,
          statusCode: statusCode,
          cause: cause,
        ),
      CacheException(:final message, :final code, :final cause) => CacheFailure(
        message: message,
        code: code,
        cause: cause,
      ),
      DatabaseException(:final message, :final code, :final cause) =>
        DatabaseFailure(message: message, code: code, cause: cause),
      ParsingException(:final message, :final code, :final cause) =>
        UnknownFailure(message: message, code: code, cause: cause),
      CancelledException(:final message, :final code, :final cause) =>
        UnknownFailure(message: message, code: code, cause: cause),
      SecurityException(:final message, :final code, :final cause) =>
        SecurityFailure(message: message, code: code, cause: cause),
      UnknownException(:final message, :final code, :final cause) =>
        UnknownFailure(message: message, code: code, cause: cause),
    };
  }

  /// Universal mapping entry point: converts any thrown error into a clean domain [Failure].
  static Failure toFailure(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) {
      return error;
    }
    if (error is DioException) {
      final appException = fromDioException(error);
      return fromAppException(appException);
    }
    if (error is AppException) {
      return fromAppException(error);
    }
    return UnknownFailure(
      message: 'An unexpected application error occurred.',
      cause: error,
    );
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      if (data['detail'] is String) return data['detail'] as String;
    }
    return null;
  }

  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    final result = <String, List<String>>{};
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      final errors = data['errors'] as Map<dynamic, dynamic>;
      for (final entry in errors.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        if (val is List) {
          result[key] = val.map((e) => e.toString()).toList();
        } else if (val is String) {
          result[key] = [val];
        }
      }
    }
    return result;
  }
}
