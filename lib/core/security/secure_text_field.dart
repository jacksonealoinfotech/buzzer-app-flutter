import 'dart:async';

import 'package:buzzer_app/core/widgets/decorations/input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureTextField extends StatefulWidget {
  const SecureTextField({
    required this.controller,
    required this.prefixIcon,
    required this.lable,
    super.key,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.visiblePassword,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.disableCopy = true,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool disableCopy;
  final IconData prefixIcon;
  final ValueChanged<String>? onChanged;
  final String lable;
  final Widget? suffix;

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      enableInteractiveSelection: !widget.disableCopy,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: decoration(
        context,
        hint: widget.hintText ?? '',
        icon: widget.prefixIcon,
        label: widget.lable,
        suffix: widget.suffix,
      ),
    );
  }
}

/// Utility for safely handling clipboard data with automatic purge.
abstract final class SecureClipboard {
  /// Copies sensitive text to clipboard and schedules automatic wipe after [timeout].
  static Future<void> copyWithAutoClear(
    String text, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    Timer(timeout, () async {
      final currentData = await Clipboard.getData(Clipboard.kTextPlain);
      if (currentData?.text == text) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }
}
