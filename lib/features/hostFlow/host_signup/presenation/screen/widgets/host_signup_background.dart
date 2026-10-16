import 'package:flutter/material.dart';

class HostSignupBackground extends StatelessWidget {
  const HostSignupBackground({required this.animation, super.key});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget blob(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
        ),
      ),
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(animation.value);
          return Stack(
            children: [
              Positioned(
                top: -80 + 30 * t,
                right: -90 + 20 * t,
                child: blob(cs.primaryContainer, 300),
              ),
              Positioned(
                bottom: -110 + 25 * (1 - t),
                left: -100 + 30 * t,
                child: blob(cs.tertiaryContainer, 320),
              ),
            ],
          );
        },
      ),
    );
  }
}
