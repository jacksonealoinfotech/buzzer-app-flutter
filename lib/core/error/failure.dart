import 'package:flutter/foundation.dart';

/// Sealed hierarchy representing domain-layer failures.
///
/// Designed to be consumed by BLoCs and Presentation layers via exhaustive
/// pattern matching (switch expressions). Does not contain low-level stack traces.
@immutable
sealed class Failure {
  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  /// User-friendly, localizable message suitable for display in UI.
  final String message;

  /// Semantic error code for localization lookup or telemetry tracking.
  final String? code;

  /// Optional underlying exception for diagnostic logging.
  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);
}

/// Device has no internet connection or network interface is down.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection detected. Please check your network.',
    super.code = 'NETWORK_ERROR',
    super.cause,
  });
}

/// Request timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request timed out. Please try again.',
    super.code = 'TIMEOUT_ERROR',
    super.cause,
  });
}

/// User authentication failed or session expired (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Your session has expired. Please sign in again.',
    super.code = 'UNAUTHORIZED_ERROR',
    super.cause,
  });
}

/// Access forbidden (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'FORBIDDEN_ERROR',
    super.cause,
  });
}

/// Resource not found (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested content could not be found.',
    super.code = 'NOT_FOUND_ERROR',
    super.cause,
  });
}

/// Validation failure (HTTP 400, 422).
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors = const <String, List<String>>{},
    super.cause,
  });

  final Map<String, List<String>> fieldErrors;
}

/// Remote backend or server failure (HTTP 5xx).
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'A server error occurred. Our engineers have been notified.',
    super.code = 'SERVER_ERROR',
    this.statusCode = 500,
    super.cause,
  });

  final int statusCode;
}

/// Local cache failure.
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Unable to read or write local cached data.',
    super.code = 'CACHE_ERROR',
    super.cause,
  });
}

/// Database failure.
final class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'A local database error occurred.',
    super.code = 'DATABASE_ERROR',
    super.cause,
  });
}

/// Security or integrity failure (e.g. Pinning mismatch, app tampered).
final class SecurityFailure extends Failure {
  const SecurityFailure({
    required super.message,
    super.code = 'SECURITY_ERROR',
    super.cause,
  });
}

/// Unclassified fallback failure.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again later.',
    super.code = 'UNKNOWN_ERROR',
    super.cause,
  });
}
