/// Sealed hierarchy of all infrastructure and data layer exceptions.
///
/// Thrown by data sources, network clients, and storage engines,
/// then mapped to domain-level [Failure]s via [ErrorMapper].
sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.cause});

  /// Technical diagnostic message.
  final String message;

  /// Internal error code (e.g. 'ERR_HTTP_404').
  final String? code;

  /// Underlying raw exception or object if available.
  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, code: $code, cause: $cause)';
}

/// Device is offline or DNS lookup failed.
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection is unavailable.',
    super.code = 'NETWORK_UNAVAILABLE',
    super.cause,
  });
}

/// Network or socket operation timed out.
final class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The operation timed out.',
    super.code = 'OPERATION_TIMEOUT',
    super.cause,
  });
}

/// HTTP 401: Authentication is missing or invalid.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'User is unauthorized or session expired.',
    super.code = 'UNAUTHORIZED',
    super.cause,
  });
}

/// HTTP 403: Caller lacks permission to access resource.
final class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access to this resource is forbidden.',
    super.code = 'FORBIDDEN',
    super.cause,
  });
}

/// HTTP 404: Resource was not found.
final class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
    super.cause,
  });
}

/// HTTP 400 or 422: Validation or bad request.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_FAILED',
    this.fieldErrors = const <String, List<String>>{},
    super.cause,
  });

  final Map<String, List<String>> fieldErrors;
}

/// HTTP 5xx: Remote server error.
final class ServerException extends AppException {
  const ServerException({
    super.message = 'An unexpected server error occurred.',
    super.code = 'SERVER_ERROR',
    this.statusCode = 500,
    super.cause,
  });

  final int statusCode;
}

/// Local cache read/write failure.
final class CacheException extends AppException {
  const CacheException({
    super.message = 'Failed to access local cache.',
    super.code = 'CACHE_ERROR',
    super.cause,
  });
}

/// SQLite database failure.
final class DatabaseException extends AppException {
  const DatabaseException({
    super.message = 'Database operation failed.',
    super.code = 'DATABASE_ERROR',
    super.cause,
  });
}

/// JSON deserialization or serialization failure.
final class ParsingException extends AppException {
  const ParsingException({
    super.message = 'Failed to parse response payload.',
    super.code = 'PARSING_ERROR',
    super.cause,
  });
}

/// Operation was cancelled by client (e.g. CancelToken).
final class CancelledException extends AppException {
  const CancelledException({
    super.message = 'The operation was cancelled.',
    super.code = 'OPERATION_CANCELLED',
    super.cause,
  });
}

/// Security violation: certificate pinning failure, tampering detected, or invalid crypto key.
final class SecurityException extends AppException {
  const SecurityException({
    required super.message,
    super.code = 'SECURITY_VIOLATION',
    super.cause,
  });
}

/// Unclassified fallback exception.
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
    super.cause,
  });
}
