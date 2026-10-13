import 'package:flutter/widgets.dart';

/// Micro-interaction widget creating a responsive tactile bounce on touch.
class TapScaleFeedback extends StatefulWidget {
  const TapScaleFeedback({
    required this.child,
    super.key,
    this.onTap,
    this.scaleDownFactor = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDownFactor;

  @override
  State<TapScaleFeedback> createState() => _TapScaleFeedbackState();
}

class _TapScaleFeedbackState extends State<TapScaleFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
