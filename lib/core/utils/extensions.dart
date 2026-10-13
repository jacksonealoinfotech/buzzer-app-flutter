import 'package:flutter/widgets.dart';

/// Ergonomic extensions for String primitives.
extension StringExtensions on String {
  /// Capitalizes first letter.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Masks string for privacy (e.g. `john***@gmail.com`).
  String mask({int visibleChars = 3}) {
    if (length <= visibleChars) return this;
    return '${substring(0, visibleChars)}${'*' * (length - visibleChars)}';
  }
}

/// Ergonomic extensions on DateTime.
extension DateTimeExtensions on DateTime {
  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

/// Ergonomic extensions on num.
extension NumExtensions on num {
  /// Convert number to vertical SizedBox gap.
  Widget get gapV => SizedBox(height: toDouble());

  /// Convert number to horizontal SizedBox gap.
  Widget get gapH => SizedBox(width: toDouble());
}

/// Ergonomic extensions on Widget.
extension WidgetExtensions on Widget {
  /// Conditionally displays widget based on [condition].
  Widget visible(bool condition) => condition ? this : const SizedBox.shrink();

  /// Wraps widget in a padding.
  Widget withPadding(EdgeInsets padding) => Padding(padding: padding, child: this);

  /// Centers widget.
  Widget centered() => Center(child: this);
}
