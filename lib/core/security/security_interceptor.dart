import 'dart:math';

import 'package:dio/dio.dart';
import 'package:buzzer_app/core/error/app_exception.dart';

/// Network security enforcement interceptor:
/// 1. Enforces HTTPS only (strictly rejects cleartext HTTP downgrades).
/// 2. Generates and injects a cryptographic `X-Request-Id` header for end-to-end tracing.
/// 3. Injects timestamp header (`X-Timestamp`) for anti-replay defense.
/// 4. Optional HMAC request signing hook (commented).
class SecurityInterceptor extends Interceptor {
  SecurityInterceptor({this.allowHttpForLocalhost = true});

  final bool allowHttpForLocalhost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;

    // 1. Enforce HTTPS: block cleartext traffic
    final isHttp = uri.scheme.toLowerCase() == 'http';
    final isLocalhost = uri.host == 'localhost' || uri.host == '127.0.0.1';

    if (isHttp && !(allowHttpForLocalhost && isLocalhost)) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const SecurityException(
            message: 'Cleartext HTTP traffic is blocked by security policy. Use HTTPS.',
          ),
          type: DioExceptionType.badCertificate,
        ),
      );
      return;
    }

    // 2. Inject Unique Request ID (UUID v4 style random hex)
    if (!options.headers.containsKey('X-Request-Id')) {
      options.headers['X-Request-Id'] = _generateRequestId();
    }

    // 3. Anti-Replay: Timestamp
    options.headers['X-Timestamp'] = DateTime.now().toUtc().toIso8601String();

    // 4. Client Platform Identity Header
    options.headers['X-Client-Platform'] = 'flutter';

    // TODO: Optional Request Signing (HMAC-SHA256)
    // If your backend requires signed requests with server-issued client keys:
    // final bodyBytes = utf8.encode(jsonEncode(options.data ?? ''));
    // final signature = Hmac(sha256, secretKey).convert(bodyBytes).toString();
    // options.headers['X-Signature'] = signature;

    handler.next(options);
  }

  /// Generates a CSPRNG request tracking identifier.
  String _generateRequestId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    // Set UUID v4 variant
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
