import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Animated expand/collapse container wrapping dynamic children.
class ExpandableSection extends StatelessWidget {
  const ExpandableSection({
    required this.isExpanded,
    required this.child,
    super.key,
    this.duration = AppDurations.normal,
    this.curve = Curves.easeInOutCubic,
  });

  final bool isExpanded;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: child,
      crossFadeState: isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: duration,
      sizeCurve: curve,
    );
  }
}
