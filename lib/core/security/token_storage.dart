/// Contract for persisting sensitive credentials (refresh tokens, crypto keys).
///
/// Follows OWASP MASVS: Access tokens MUST remain in-memory only.
/// Refresh tokens and encryption keys must be kept in hardware-backed secure storage.
abstract interface class TokenStorage {
  /// Reads the stored refresh token.
  Future<String?> getRefreshToken();

  /// Persists a new refresh token.
  Future<void> saveRefreshToken(String token);

  /// Deletes the stored refresh token.
  Future<void> deleteRefreshToken();

  /// Wipes all sensitive credentials stored by this provider.
  Future<void> clearAll();
}
