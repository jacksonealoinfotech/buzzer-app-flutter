import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// Diagnostics logger that automatically masks PII and secrets from all outputs.
///
/// Complies with OWASP MASVS: Tokens, credit card numbers, passwords, emails,
/// and bearer headers are sanitized before printing or storing in memory.
final class RedactingLogger {
  RedactingLogger([Talker? talker])
      : _talker = talker ??
            Talker(
              settings: TalkerSettings(
                enabled: kDebugMode, // Disabled or minimized in release builds
                useConsoleLogs: kDebugMode,
              ),
            );

  final Talker _talker;

  Talker get talkerInstance => _talker;

  static final RegExp _bearerPattern =
      RegExp(r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*', caseSensitive: false);
  static final RegExp _secretJsonPattern = RegExp(
    r'("password"|"secret"|"token"|"refreshToken"|"accessToken")\s*:\s*"[^"]*"',
    caseSensitive: false,
  );
  static final RegExp _emailPattern =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _cardPattern =
      RegExp(r'\b(?:\d[ -]*?){13,16}\b');
  static final RegExp _phonePattern =
      RegExp(r'\+?[0-9]{1,3}?[-. ]?\(?[0-9]{2,3}?\)?[-. ]?[0-9]{3,5}[-. ]?[0-9]{4}');

  /// Masks sensitive patterns in [input].
  static String redact(String input) {
    var sanitized = input;
    sanitized = sanitized.replaceAllMapped(_bearerPattern, (_) => 'Bearer [REDACTED]');
    sanitized = sanitized.replaceAllMapped(_secretJsonPattern, (match) {
      final key = (match.group(0) ?? '').split(':').first;
      return '$key: "[REDACTED]"';
    });
    sanitized = sanitized.replaceAllMapped(_emailPattern, (_) => '[REDACTED_EMAIL]');
    sanitized = sanitized.replaceAllMapped(_cardPattern, (_) => '[REDACTED_CARD]');
    sanitized = sanitized.replaceAllMapped(_phonePattern, (_) => '[REDACTED_PHONE]');
    return sanitized;
  }

  void debug(String message) {
    if (!kDebugMode) return;
    _talker.debug(redact(message));
  }

  void info(String message) {
    _talker.info(redact(message));
  }

  void warning(String message) {
    _talker.warning(redact(message));
  }

  void error(String message, [Object? exception, StackTrace? stackTrace]) {
    _talker.error(redact(message), exception, stackTrace);
  }

  void critical(String message, [Object? exception, StackTrace? stackTrace]) {
    _talker.critical(redact(message), exception, stackTrace);
  }
}
