import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Ergonomic navigation shortcuts on [BuildContext].
extension NavigationContextExtension on BuildContext {
  /// Pops current route if can pop.
  void popOrFallback([String fallbackPath = '/']) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackPath);
    }
  }
}
