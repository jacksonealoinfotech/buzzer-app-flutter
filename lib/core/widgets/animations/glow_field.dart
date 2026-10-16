import 'package:flutter/material.dart';

class GlowField extends StatelessWidget {
  const GlowField({required this.focusNode, required this.child, super.key});

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: focusNode.hasFocus
                    ? cs.primary.withValues(alpha: 0.18)
                    : cs.shadow.withValues(alpha: 0.04),
                blurRadius: focusNode.hasFocus ? 18 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
