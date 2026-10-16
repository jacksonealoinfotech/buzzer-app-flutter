import 'package:flutter/material.dart';

InputDecoration decoration(
  BuildContext context, {
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  final cs = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.35)),
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: cs.surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: border(cs.outlineVariant),
    enabledBorder: border(cs.outlineVariant),
    focusedBorder: border(cs.primary, 1.8),
    errorBorder: border(cs.error),
    focusedErrorBorder: border(cs.error, 1.8),
    disabledBorder: border(cs.outlineVariant.withValues(alpha: 0.5)),
    errorStyle: TextStyle(color: cs.error),
  );
}
