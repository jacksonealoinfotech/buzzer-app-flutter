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

  Future<void> wipeAll() async {
    await _tokenManager.clearTokens();

    // 2. Wipe secure key-value store
    await _secureStorageService.deleteAll();

    // 3. Wipe SQLite database if hook provided
    if (_onDatabaseWipe != null) {
      await _onDatabaseWipe();
    }
  }
}
