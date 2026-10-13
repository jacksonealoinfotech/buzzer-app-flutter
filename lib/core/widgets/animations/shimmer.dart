import 'package:flutter/material.dart';
import 'package:buzzer_app/core/theme/app_colors.dart';
import 'package:buzzer_app/core/theme/theme_context_extensions.dart';

/// Shimmer skeleton loading effect without external package dependencies.
///
/// Sweeps a highlight gradient across its child on a continuous loop.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Factory creating rectangular skeleton placeholder.
  factory AppShimmer.box({
    required double width,
    required double height,
    double borderRadius = 8.0,
    Key? key,
  }) {
    return AppShimmer(
      key: key,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Factory creating circular skeleton placeholder (e.g. Avatars).
  factory AppShimmer.circle({required double size, Key? key}) {
    return AppShimmer(
      key: key,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    final isDark = context.isDark;
    final base =
        widget.baseColor ??
        (isDark ? AppColors.shimmerDarkBase : AppColors.shimmerBase);
    final highlight =
        widget.highlightColor ??
        (isDark ? AppColors.shimmerDarkHighlight : AppColors.shimmerHighlight);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}
