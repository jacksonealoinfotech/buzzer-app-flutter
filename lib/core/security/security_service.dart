import 'package:buzzer_app/core/security/secure_storage_service.dart';
import 'package:buzzer_app/core/security/token_manager.dart';

/// Central application security orchestrator providing system-wide wiping and compliance tools.
final class SecurityService {
  SecurityService({
    required TokenManager tokenManager,
    required SecureStorageService secureStorageService,
    Future<void> Function()? onDatabaseWipe,
  }) : _tokenManager = tokenManager,
       _secureStorageService = secureStorageService,
       _onDatabaseWipe = onDatabaseWipe;

  final TokenManager _tokenManager;
  final SecureStorageService _secureStorageService;
  final Future<void> Function()? _onDatabaseWipe;

  /// Comprehensive system-wide wipe (OWASP MASVS Right-to-Erase / Emergency Purge).
  ///
  /// Clears:
  /// - In-memory access token & authentication state
  /// - Hardware-backed secure storage (refresh token, encryption keys)
  /// - Local encrypted SQLite database
  /// - In-memory caches and active sessions
  ///
  /// Invoked on: user logout, account deletion, refresh token rejection/tampering,
  /// or root/jailbreak detection block policy.
  Future<void> wipeAll() async {
    // 1. Wipe credentials
    await _tokenManager.clearTokens();

    // 2. Wipe secure key-value store
    await _secureStorageService.deleteAll();

    // 3. Wipe SQLite database if hook provided
    if (_onDatabaseWipe != null) {
      await _onDatabaseWipe();
    }
  }
}
