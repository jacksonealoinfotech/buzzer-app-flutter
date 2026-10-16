import 'dart:math' as math;

import 'package:flutter/material.dart';

class HostSignupPassword extends StatelessWidget {
  const HostSignupPassword({required this.controller, super.key});

  final TextEditingController controller;

  static const _labels = ['Weak', 'Fair', 'Good', 'Strong'];

  int _score(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    if (p.length < 8) s = math.min(s, 1);
    return math.max(s, 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final colors = [cs.error, cs.secondary, cs.tertiary, cs.primary];

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.text;
        final visible = p.isNotEmpty;
        final score = visible ? _score(p) : 0;
        final color = visible ? colors[score - 1] : cs.outlineVariant;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: !visible
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(4, (i) {
                            final active = i < score;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 5,
                                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: active
                                      ? color
                                      : cs.outlineVariant.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: (text.labelMedium ?? const TextStyle()).copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                        child: Text(_labels[score - 1]),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
