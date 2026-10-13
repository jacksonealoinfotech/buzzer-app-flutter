import 'package:flutter/material.dart';
import 'package:buzzer_app/core/responsive/app_spacing.dart';
import 'package:buzzer_app/core/theme/theme_context_extensions.dart';
import 'package:buzzer_app/core/widgets/buttons/app_button.dart';

/// Empty state illustration view.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = 'No Data Found',
    this.message = 'There are no items to display at this moment.',
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: colors.outline),
            Gap.v16,
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.v8,
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              Gap.v24,
              AppButton(
                text: actionText!,
                onPressed: onAction,
                variant: ButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic error state view with retry action button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    super.key,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryText = 'Try Again',
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: colors.error),
            Gap.v16,
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.v8,
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              Gap.v24,
              AppButton(
                text: retryText,
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No internet connectivity state view.
class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: 'No Internet Connection',
      message:
          'Please check your Wi-Fi or cellular network settings and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
}

/// Server maintenance mode view.
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle_outlined, size: 80, color: colors.primary),
            Gap.v16,
            Text(
              'Under Scheduled Maintenance',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.v8,
            Text(
              'We are currently performing scheduled maintenance. Please check back shortly.',
              style: textTheme.bodyMedium?.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
