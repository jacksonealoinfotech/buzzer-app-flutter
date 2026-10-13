import 'package:flutter/widgets.dart';

/// Material 3 Window Size Classes.
enum WindowSizeClass {
  /// Handset in portrait mode (< 600dp).
  compact,

  /// Tablets, foldables, and handsets in landscape (600dp - 840dp).
  medium,

  /// Tablets in landscape, desktop monitors (> 840dp).
  expanded;

  bool get isCompact => this == WindowSizeClass.compact;
  bool get isMedium => this == WindowSizeClass.medium;
  bool get isExpanded => this == WindowSizeClass.expanded;
}

/// Breakpoint width thresholds conforming to Material Design 3 guidelines.
abstract final class Breakpoints {
  /// Compact upper bound.
  static const double compactMax = 599.0;

  /// Medium lower bound.
  static const double mediumMin = 600.0;

  /// Medium upper bound.
  static const double mediumMax = 839.0;

  /// Expanded lower bound.
  static const double expandedMin = 840.0;

  /// Resolves [WindowSizeClass] for a given width.
  static WindowSizeClass fromWidth(double width) {
    if (width < mediumMin) return WindowSizeClass.compact;
    if (width <= mediumMax) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }

  /// Resolves [WindowSizeClass] efficiently using [MediaQuery.sizeOf].
  static WindowSizeClass fromContext(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }
}
