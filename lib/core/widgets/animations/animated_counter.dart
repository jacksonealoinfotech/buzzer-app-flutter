import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Smooth ticker counter with slide transitions.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.count,
    super.key,
    this.style,
    this.duration = AppDurations.normal,
  });

  final int count;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text('$count', key: ValueKey<int>(count), style: style),
    );
  }
}
