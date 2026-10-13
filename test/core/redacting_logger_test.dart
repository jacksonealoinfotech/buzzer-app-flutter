import 'package:flutter_test/flutter_test.dart';
import 'package:buzzer_app/core/security/redacting_logger.dart';

void main() {
  group('RedactingLogger PII Sanitization Tests', () {
    test('Redacts Bearer authorization tokens', () {
      const input =
          'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz.123';
      final redacted = RedactingLogger.redact(input);
      expect(redacted.contains('Bearer [REDACTED]'), isTrue);
      expect(redacted.contains('eyJhbGci'), isFalse);
    });

    test('Redacts email addresses', () {
      const input = 'User customer@domain.com performed checkout';
      final redacted = RedactingLogger.redact(input);
      expect(redacted.contains('[REDACTED_EMAIL]'), isTrue);
      expect(redacted.contains('customer@domain.com'), isFalse);
    });

    test('Redacts credit card numbers', () {
      const input = 'Card 4111-2222-3333-4444 approved';
      final redacted = RedactingLogger.redact(input);
      expect(redacted.contains('[REDACTED_CARD]'), isTrue);
      expect(redacted.contains('4111-2222-3333-4444'), isFalse);
    });

    test('Redacts password JSON values', () {
      const input = '{"username": "admin", "password": "SuperSecret123!"}';
      final redacted = RedactingLogger.redact(input);
      expect(redacted.contains('"password": "[REDACTED]"'), isTrue);
      expect(redacted.contains('SuperSecret123!'), isFalse);
    });
  });
}
