import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Supported custom page transitions for [GoRoute] builder methods.
enum AppTransitionType {
  slideFromBottom,
  slideFromRight,
  slideFromLeft,
  fade,
  scale,
  fadeThrough,
  none,
}

/// Helper building platform-aware, high-performance [CustomTransitionPage] instances.
abstract final class PageTransitions {
  /// Builds a [CustomTransitionPage] configured with selected [transitionType].
  static CustomTransitionPage<T> build<T>({
    required LocalKey key,
    required Widget child,
    AppTransitionType transitionType = AppTransitionType.slideFromRight,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context) ||
            transitionType == AppTransitionType.none) {
          return child;
        }

        return switch (transitionType) {
          AppTransitionType.slideFromBottom => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
          AppTransitionType.slideFromRight => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
          AppTransitionType.slideFromLeft => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
          AppTransitionType.fade => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
          AppTransitionType.scale => ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          ),
          AppTransitionType.fadeThrough => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          ),
          AppTransitionType.none => child,
        };
      },
    );
  }
}
