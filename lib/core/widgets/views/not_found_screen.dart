import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buzzer_app/core/responsive/app_spacing.dart';
import 'package:buzzer_app/core/theme/theme_context_extensions.dart';
import 'package:buzzer_app/core/widgets/buttons/app_button.dart';

/// 404 Page Not Found screen rendered on unmatched deep links or route errors.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;

    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: colors.error),
              Gap.v16,
              Text(
                '404 - Route Not Found',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Gap.v8,
              Text(
                errorMessage ?? 'The screen you requested does not exist or has been moved.',
                style: textTheme.bodyMedium?.copyWith(color: colors.outline),
                textAlign: TextAlign.center,
              ),
              Gap.v24,
              AppButton(
                text: 'Go to Home',
                icon: const Icon(Icons.home_rounded, size: 18),
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
