import 'package:flutter/material.dart';
import 'package:buzzer_app/core/responsive/app_sizes.dart';
import 'package:buzzer_app/core/theme/theme_context_extensions.dart';
import 'package:buzzer_app/core/widgets/animations/tap_scale_feedback.dart';

/// Supported button styling variants.
enum ButtonVariant { primary, secondary, outlined, text, tonal, danger }

/// Production-grade accessible button component.
///
/// Features:
/// - 48dp minimum accessible touch target.
/// - Built-in loading state with spinner.
/// - Icon prefix/suffix support.
/// - Micro-interaction tactile feedback via [TapScaleFeedback].
/// - Semantic accessibility labels.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height = AppSizes.buttonMd,
    this.semanticLabel,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double height;
  final String? semanticLabel;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _loadingSpinnerColor(colors),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );

    final style = _buttonStyle(context, colors);

    Widget button = switch (variant) {
      ButtonVariant.primary => FilledButton(
        style: style,
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
      ButtonVariant.secondary => ElevatedButton(
        style: style,
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
      ButtonVariant.outlined => OutlinedButton(
        style: style,
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
      ButtonVariant.text => TextButton(
        style: style,
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
      ButtonVariant.tonal => FilledButton.tonal(
        style: style,
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
      ButtonVariant.danger => FilledButton(
        style: style.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colors.error.withValues(alpha: 0.38)
                : colors.error,
          ),
          foregroundColor: WidgetStateProperty.all(colors.onError),
        ),
        onPressed: _isEnabled ? onPressed : null,
        child: buttonChild,
      ),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, height: height, child: button);
    } else {
      button = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height,
          minWidth: AppSizes.minTouchTarget,
        ),
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: semanticLabel ?? text,
      child: TapScaleFeedback(
        onTap: _isEnabled ? onPressed : null,
        child: button,
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context, ColorScheme colors) {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(AppSizes.minTouchTarget, height),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _loadingSpinnerColor(ColorScheme colors) {
    return switch (variant) {
      ButtonVariant.primary || ButtonVariant.danger => colors.onPrimary,
      ButtonVariant.secondary => colors.primary,
      ButtonVariant.outlined || ButtonVariant.text => colors.primary,
      ButtonVariant.tonal => colors.onSecondaryContainer,
    };
  }
}
