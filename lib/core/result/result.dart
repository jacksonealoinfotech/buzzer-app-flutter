import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:buzzer_app/core/error/error_mapper.dart';
import 'package:buzzer_app/core/error/failure.dart';

/// Sealed functional return type representing either a [Success] with value [T]
/// or a [FailureResult] with domain [Failure].
///
/// Eliminates runtime exceptions in application code. Repositories return `Result<T>`,
/// and presentation layers consume results via exhaustive pattern matching.
///
/// Example:
/// ```dart
/// final result = await safeCall(() => remoteDataSource.fetchUser());
/// switch (result) {
///   case Success(:final data):
///     emit(UserState.loaded(data));
///   case FailureResult(:final failure):
///     emit(UserState.error(failure.message));
/// }
/// ```
@immutable
sealed class Result<T> {
  const Result();

  /// Creates a successful result holding [data].
  const factory Result.success(T data) = Success<T>;

  /// Creates a failed result holding [failure].
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// Pattern matching handler executing [onSuccess] or [onFailure].
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      FailureResult(:final failure) => onFailure(failure),
    };
  }

  /// Transforms the success value [T] to [R] if present.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result<R>.success(transform(data)),
      FailureResult(:final failure) => Result<R>.failure(failure),
    };
  }

  /// Transforms the failure to another [Failure] if present.
  Result<T> mapFailure(Failure Function(Failure failure) transform) {
    return switch (this) {
      Success(:final data) => Result<T>.success(data),
      FailureResult(:final failure) => Result<T>.failure(transform(failure)),
    };
  }

  /// Collapses the result into a single value [R].
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      FailureResult(:final failure) => onFailure(failure),
    };
  }

  /// Returns the underlying [data] if success, otherwise returns [defaultValue].
  T getOrElse(T Function(Failure failure) defaultValue) {
    return switch (this) {
      Success(:final data) => data,
      FailureResult(:final failure) => defaultValue(failure),
    };
  }

  /// Returns the underlying [data] if success, otherwise `null`.
  T? getOrNull() {
    return switch (this) {
      Success(:final data) => data,
      FailureResult() => null,
    };
  }

  /// Executes [callback] if the result is [Success]. Returns this result for chaining.
  Result<T> onSuccess(void Function(T data) callback) {
    if (this case Success(:final data)) {
      callback(data);
    }
    return this;
  }

  /// Executes [callback] if the result is [FailureResult]. Returns this result for chaining.
  Result<T> onFailure(void Function(Failure failure) callback) {
    if (this case FailureResult(:final failure)) {
      callback(failure);
    }
    return this;
  }
}

/// Success branch of [Result].
@immutable
final class Success<T> extends Result<T> {
  const Success(this.data);

  /// Carried successful payload.
  final T data;

  @override
  String toString() => 'Result.success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

/// Failure branch of [Result].
@immutable
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  /// Domain-level failure representation.
  final Failure failure;

  @override
  String toString() => 'Result.failure($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}

/// The SINGLE standardized try/catch execution boundary in the application.
///
/// Wraps an asynchronous operation [call], maps any thrown exceptions
/// via [ErrorMapper.toFailure] (or an optional [customMapper]), and guarantees
/// a returned [Result<T>] without letting uncaught exceptions escape.
Future<Result<T>> safeCall<T>(
  Future<T> Function() call, {
  Failure Function(Object error, StackTrace stackTrace)? customMapper,
}) async {
  try {
    final response = await call();
    return Result<T>.success(response);
  } catch (error, stackTrace) {
    final failure = customMapper != null
        ? customMapper(error, stackTrace)
        : ErrorMapper.toFailure(error, stackTrace);
    return Result<T>.failure(failure);
  }
}

/// Synchronous counterpart of [safeCall].
Result<T> safeCallSync<T>(
  T Function() call, {
  Failure Function(Object error)? customMapper,
}) {
  try {
    final response = call();
    return Result<T>.success(response);
  } catch (error, stackTrace) {
    final failure = customMapper != null
        ? customMapper(error)
        : ErrorMapper.toFailure(error, stackTrace);
    return Result<T>.failure(failure);
  }
}
