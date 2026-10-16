import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buzzer_app/core/constants/storage_keys.dart';
import 'package:buzzer_app/core/security/token_manager.dart';
import 'package:buzzer_app/core/security/token_storage.dart';

class MockTokenStorage implements TokenStorage {
  String? storedRefreshToken;
  bool wasCleared = false;

  @override
  Future<String?> getRefreshToken() async => storedRefreshToken;

  @override
  Future<void> saveRefreshToken(String token) async {
    storedRefreshToken = token;
  }

  @override
  Future<void> deleteRefreshToken() async {
    storedRefreshToken = null;
  }

  @override
  Future<void> clearAll() async {
    storedRefreshToken = null;
    wasCleared = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTokenStorage tokenStorage;
  late SharedPreferences preferences;
  late TokenManager tokenManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    tokenStorage = MockTokenStorage();
    tokenManager = TokenManager(
      tokenStorage: tokenStorage,
      preferences: preferences,
    );
  });

  group('TokenManager OWASP MASVS Tests', () {
    test('Wipes stale Keychain on fresh installation launch', () async {
      tokenStorage.storedRefreshToken = 'stale_token_from_previous_install';
      expect(preferences.getBool(StorageKeys.hasRunBefore), isNull);

      await tokenManager.initialize();

      expect(tokenStorage.wasCleared, isTrue);
      expect(preferences.getBool(StorageKeys.hasRunBefore), isTrue);
    });

    test('Access token is retained in-memory only', () async {
      await tokenManager.saveTokens(
        accessToken: 'memory_access_token_123',
        refreshToken: 'secure_refresh_token_456',
      );

      expect(tokenManager.getAccessToken(), equals('memory_access_token_123'));
      expect(tokenManager.isAuthenticated, isTrue);
      expect(
        await tokenStorage.getRefreshToken(),
        equals('secure_refresh_token_456'),
      );
    });

    test('Restores authenticated state from stored refresh token', () async {
      await tokenManager.initialize();
      await tokenManager.saveTokens(
        accessToken: 'memory_access_token_123',
        refreshToken: 'secure_refresh_token_456',
      );

      final restartedTokenManager = TokenManager(
        tokenStorage: tokenStorage,
        preferences: preferences,
      );
      await restartedTokenManager.initialize();

      expect(restartedTokenManager.getAccessToken(), isNull);
      expect(restartedTokenManager.isAuthenticated, isTrue);
      restartedTokenManager.dispose();
    });

    test(
      'Single-flight refresh prevents parallel duplicate refreshes',
      () async {
        await tokenManager.saveTokens(
          accessToken: 'expired_access',
          refreshToken: 'valid_refresh',
        );

        var refreshCallCount = 0;

        Future<(String, String?)> mockRefreshCall(String refresh) async {
          refreshCallCount++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return ('new_access_token', 'new_rotated_refresh_token');
        }

        // Fire 3 simultaneous refresh operations
        final results = await Future.wait([
          tokenManager.singleFlightRefresh(
            refreshCall: mockRefreshCall,
            onRefreshFailed: () async {},
          ),
          tokenManager.singleFlightRefresh(
            refreshCall: mockRefreshCall,
            onRefreshFailed: () async {},
          ),
          tokenManager.singleFlightRefresh(
            refreshCall: mockRefreshCall,
            onRefreshFailed: () async {},
          ),
        ]);

        // Exactly ONE network refresh call should have occurred
        expect(refreshCallCount, equals(1));
        expect(results[0], equals('new_access_token'));
        expect(results[1], equals('new_access_token'));
        expect(results[2], equals('new_access_token'));
        expect(
          await tokenStorage.getRefreshToken(),
          equals('new_rotated_refresh_token'),
        );
      },
    );

    test('Clear tokens completely wipes memory and secure storage', () async {
      await tokenManager.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      );

      await tokenManager.clearTokens();

      expect(tokenManager.getAccessToken(), isNull);
      expect(tokenManager.isAuthenticated, isFalse);
      expect(await tokenStorage.getRefreshToken(), isNull);
    });
  });
}
