import 'package:flutter/foundation.dart';
import 'package:buzzer_app/core/result/result.dart';

/// Base contract for asynchronous single-execution Clean Architecture use cases.
///
/// Example:
/// ```dart
/// class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
///   final UserRepository _repository;
///   GetUserProfileUseCase(this._repository);
///
///   @override
///   Future<Result<UserProfile>> call(NoParams params) {
///     return _repository.getUserProfile();
///   }
/// }
/// ```
abstract interface class UseCase<T, Params> {
  /// Executes business logic and returns a sealed [Result].
  Future<Result<T>> call(Params params);
}

/// Base contract for reactive continuous-stream Clean Architecture use cases.
///
/// Example:
/// ```dart
/// class WatchThemeModeUseCase implements StreamUseCase<ThemeMode, NoParams> {
///   final ThemeRepository _repository;
///   WatchThemeModeUseCase(this._repository);
///
///   @override
///   Stream<Result<ThemeMode>> call(NoParams params) {
///     return _repository.watchThemeMode();
///   }
/// }
/// ```
abstract interface class StreamUseCase<T, Params> {
  /// Returns a stream of sealed [Result] items.
  Stream<Result<T>> call(Params params);
}

/// Sentinel parameter class for use cases that require no arguments.
@immutable
final class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => identical(this, other) || other is NoParams;

  @override
  int get hashCode => 0;
}
