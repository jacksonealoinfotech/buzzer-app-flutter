import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

HttpClientAdapter createCertificatePinningAdapter({
  required List<String> allowedPins,
  bool isEnabled = true,
}) {
  if (kIsWeb) {
    return HttpClientAdapter();
  }

  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
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

      final digest = sha256.convert(cert.der);
      final fingerprint = base64.encode(digest.bytes);

      final matches = allowedPins.any(
        (pin) => pin.trim() == fingerprint.trim(),
      );

      return matches;
    },
  );
}
