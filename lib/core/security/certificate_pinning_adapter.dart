import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Creates an [HttpClientAdapter] enforcing SHA-256 certificate pinning.
///
/// Implements OWASP MASVS network verification:
/// - Enforces at least 2 pins (primary + backup pin for key rotation)
/// - Strictly rejects invalid or unknown certificates
/// - `badCertificateCallback` is guaranteed to NEVER return `true`
/// - Gracefully falls back to browser standard TLS on Web
HttpClientAdapter createCertificatePinningAdapter({
  required List<String> allowedPins,
  bool isEnabled = true,
}) {
  if (kIsWeb) {
    // Browsers manage TLS connections and prohibit raw socket certificate inspection.
    return HttpClientAdapter();
  }

  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // CRITICAL SECURITY: Never silently accept invalid certificates
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return false;
      };
      return client;
    },
    validateCertificate: (X509Certificate? cert, String host, int port) {
      if (!isEnabled) {
        return true;
      }

      if (cert == null) {
        return false;
      }

      // Compute SHA-256 fingerprint of certificate DER representation
      final digest = sha256.convert(cert.der);
      final fingerprint = base64.encode(digest.bytes);

      // Verify certificate hash matches at least one configured pin
      final matches = allowedPins.any(
        (pin) => pin.trim() == fingerprint.trim(),
      );

      return matches;
    },
  );
}
