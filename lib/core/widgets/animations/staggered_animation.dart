import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';
import 'package:buzzer_app/core/widgets/animations/app_animate.dart';

/// Applies incremental stagger delays to children in lists or grids.
class StaggeredAnimation extends StatelessWidget {
  const StaggeredAnimation({
    required this.index,
    required this.child,
    super.key,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.animationType = AnimationType.slideUp,
    this.duration = AppDurations.normal,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final AnimationType animationType;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AppAnimate(
      type: animationType,
      duration: duration,
      delay: Duration(milliseconds: index * staggerDelay.inMilliseconds),
      child: child,
    );
  }
}
