/// Form input validation rules and error message generators.
abstract final class Validators {
  static final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  /// Validates that a string is not empty or whitespace only.
  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Validates standard email address format.
  static String? email(String? value, [String message = 'Enter a valid email address']) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  /// Validates minimum string length.
  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.length < min) {
      return message ?? 'Must be at least $min characters';
    }
    return null;
  }

  /// Validates strong password rules: 8+ chars, 1 uppercase, 1 lowercase, 1 number.
  static String? strongPassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain at least 1 lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain at least 1 number';
    }
    return null;
  }

  /// Validates matching confirmation field (e.g. password confirmation).
  static String? match(String? value, String? target, [String message = 'Values do not match']) {
    if (value != target) {
      return message;
    }
    return null;
  }
}
