import 'package:flutter/widgets.dart';
import 'package:buzzer_app/core/responsive/breakpoints.dart';

/// Renders different UI trees depending on the active [WindowSizeClass].
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    required this.compact,
    super.key,
    this.medium,
    this.expanded,
  });

  /// Widget builder for compact (mobile) displays.
  final WidgetBuilder compact;

  /// Optional widget builder for medium (tablet / foldable) displays.
  final WidgetBuilder? medium;

  /// Optional widget builder for expanded (desktop) displays.
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = Breakpoints.fromWidth(constraints.maxWidth);

        return switch (sizeClass) {
          WindowSizeClass.compact => compact(context),
          WindowSizeClass.medium => (medium ?? compact)(context),
          WindowSizeClass.expanded => (expanded ?? medium ?? compact)(context),
        };
      },
    );
  }
}
