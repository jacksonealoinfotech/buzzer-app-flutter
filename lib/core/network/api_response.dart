/// Standardized JSON API envelope model.
final class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
    this.errors = const {},
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      code: json['code'] as String?,
      errors: (json['errors'] as Map<String, dynamic>?) ?? const {},
    );
  }

  final bool success;
  final T? data;
  final String? message;
  final String? code;
  final Map<String, dynamic> errors;
}
