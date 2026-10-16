/// Centralized API paths and route constants.
abstract final class ApiEndpoints {
  // Base API Version
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String registerAdmin = '$apiVersion/auth/register/admin';
  static const String registerHost = '$apiVersion/auth/register/host';
  static const String registerPlayer = '$apiVersion/auth/register/player';

  // User & Profile
  static const String userProfile = '$apiVersion/users/me';

  // Demo / Showcase Mock Endpoint
  static const String sampleItems = '$apiVersion/items';
}
