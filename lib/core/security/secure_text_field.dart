import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Security-hardened text entry field designed for passwords, PINs, and credentials.
///
/// Features:
/// - `enableSuggestions: false` and `autocorrect: false` to prevent keyboard dictionary learning.
/// - Obscure text toggle with accessible iconography.
/// - Optional clipboard copy suppression (`disableCopy`).
/// - Auto-clearing clipboard utility (`SecureClipboard.copyWithAutoClear`).
class SecureTextField extends StatefulWidget {
  const SecureTextField({
    required this.controller,
    super.key,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.visiblePassword,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.disableCopy = true,
    this.prefixIcon,
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
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

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
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          tooltip: _obscureText ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
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
