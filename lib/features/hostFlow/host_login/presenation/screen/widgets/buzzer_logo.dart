import 'package:flutter/material.dart';

class BuzzerLogo extends StatelessWidget {
  const BuzzerLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          'Buzzer',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}
