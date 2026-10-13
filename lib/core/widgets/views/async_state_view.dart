import 'package:flutter/material.dart';
import 'package:buzzer_app/core/error/failure.dart';
import 'package:buzzer_app/core/result/result.dart';
import 'package:buzzer_app/core/widgets/views/state_views.dart';

/// Generic widget rendering async states: initial, loading, empty, error, and success.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    required this.result,
    required this.dataBuilder,
    super.key,
    this.isLoading = false,
    this.initialBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onRetry,
    this.isEmptyPredicate,
  });

  /// The active [Result], if resolved.
  final Result<T>? result;

  /// Whether asynchronous execution is actively underway.
  final bool isLoading;

  /// Builder when [result] is [Success].
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// Custom initial placeholder builder.
  final WidgetBuilder? initialBuilder;

  /// Custom loading state builder.
  final WidgetBuilder? loadingBuilder;

  /// Custom empty state builder.
  final WidgetBuilder? emptyBuilder;

  /// Custom error builder receiving domain [Failure].
  final Widget Function(BuildContext context, Failure failure)? errorBuilder;

  /// Retry callback passed to default [ErrorView].
  final VoidCallback? onRetry;

  /// Optional predicate to test if data should be treated as empty (e.g. `(list) => list.isEmpty`).
  final bool Function(T data)? isEmptyPredicate;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    if (result == null) {
      return initialBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return switch (result!) {
      Success(:final data) => () {
        if (isEmptyPredicate != null && isEmptyPredicate!(data)) {
          return emptyBuilder?.call(context) ?? const EmptyView();
        }
        return dataBuilder(context, data);
      }(),
      FailureResult(:final failure) =>
        errorBuilder != null
            ? errorBuilder!(context, failure)
            : failure is NetworkFailure
            ? NoInternetView(onRetry: onRetry)
            : ErrorView(message: failure.message, onRetry: onRetry),
    };
  }
}
