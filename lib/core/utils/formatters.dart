import 'package:intl/intl.dart';

/// Formatting utilities for dates, currency, and file byte sizes.
abstract final class Formatters {
  static final DateFormat _shortDate = DateFormat('MMM d, y');
  static final DateFormat _dateTime = DateFormat('MMM d, y • HH:mm');
  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$');

  /// Formats date to `Oct 9, 2026`.
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _shortDate.format(date);
  }

  /// Formats date and time to `Oct 9, 2026 • 14:30`.
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTime.format(date);
  }

  /// Formats number to currency string `\$1,234.50`.
  static String formatCurrency(num amount) {
    return _currency.format(amount);
  }

  /// Formats raw byte count to readable metric string (`12.4 MB`).
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
