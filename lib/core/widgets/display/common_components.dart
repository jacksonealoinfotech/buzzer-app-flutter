import 'package:flutter/material.dart';
import 'package:buzzer_app/core/responsive/app_sizes.dart';
import 'package:buzzer_app/core/responsive/app_spacing.dart';
import 'package:buzzer_app/core/theme/theme_context_extensions.dart';

/// User profile avatar with initials fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.size = AppSizes.avatarMd,
  });

  final String? imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = _getInitials(name);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  String _getInitials(String string) {
    if (string.trim().isEmpty) return '?';
    final parts = string.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Section title header with optional trailing action button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionText!)),
        ],
      ),
    );
  }
}

/// Star rating indicator component.
class RatingBar extends StatelessWidget {
  const RatingBar({
    required this.rating,
    super.key,
    this.maxRating = 5,
    this.starSize = 18.0,
    this.color = Colors.amber,
  });

  final double rating;
  final int maxRating;
  final double starSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final icon = index < rating
            ? (index + 0.5 <= rating
                  ? Icons.star_rounded
                  : Icons.star_half_rounded)
            : Icons.star_outline_rounded;
        return Icon(icon, size: starSize, color: color);
      }),
    );
  }
}

/// Expandable accordion list tile.
class ExpandableTile extends StatelessWidget {
  const ExpandableTile({
    required this.title,
    required this.children,
    super.key,
    this.leading,
    this.subtitle,
    this.initiallyExpanded = false,
  });

  final Widget title;
  final List<Widget> children;
  final Widget? leading;
  final Widget? subtitle;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: title,
        leading: leading,
        subtitle: subtitle,
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        childrenPadding: const EdgeInsets.all(AppSpacing.md),
        children: children,
      ),
    );
  }
}
