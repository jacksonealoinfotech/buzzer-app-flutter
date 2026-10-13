import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Supported atomic animation types.
enum AnimationType {
  fadeIn,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  bounce,
  pulse,
  shake,
  rotate,
  blurIn,
}

/// Accessible animation wrapper honoring `MediaQuery.disableAnimationsOf(context)`.
///
/// Configurable duration, curve, delay, and chaining.
class AppAnimate extends StatefulWidget {
  const AppAnimate({
    required this.child,
    super.key,
    this.type = AnimationType.fadeIn,
    this.duration = AppDurations.normal,
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.repeat = false,
  });

  final Widget child;
  final AnimationType type;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool repeat;

  @override
  State<AppAnimate> createState() => _AppAnimateState();
}

class _AppAnimateState extends State<AppAnimate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.delay == Duration.zero) {
      _start();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _start();
      });
    }
  }

  void _start() {
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ACCESSIBILITY: Honor system reduce-motion preference
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        return switch (widget.type) {
          AnimationType.fadeIn => Opacity(opacity: value, child: child),
          AnimationType.slideUp => Transform.translate(
            offset: Offset(0, 30 * (1.0 - value)),
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.slideDown => Transform.translate(
            offset: Offset(0, -30 * (1.0 - value)),
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.slideLeft => Transform.translate(
            offset: Offset(30 * (1.0 - value), 0),
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.slideRight => Transform.translate(
            offset: Offset(-30 * (1.0 - value), 0),
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.scale => Transform.scale(
            scale: 0.85 + (0.15 * value),
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.bounce => Transform.scale(
            scale: 0.5 + (0.5 * value),
            child: child,
          ),
          AnimationType.pulse => Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
          AnimationType.shake => Transform.translate(
            offset: Offset(
              10 * (1.0 - value) * ((value * 10) % 2 == 0 ? 1 : -1),
              0,
            ),
            child: child,
          ),
          AnimationType.rotate => Transform.rotate(
            angle: (1.0 - value) * 0.2,
            child: Opacity(opacity: value, child: child),
          ),
          AnimationType.blurIn => ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 10 * (1.0 - value),
              sigmaY: 10 * (1.0 - value),
            ),
            child: Opacity(opacity: value, child: child),
          ),
        };
      },
      child: widget.child,
    );
  }
}
