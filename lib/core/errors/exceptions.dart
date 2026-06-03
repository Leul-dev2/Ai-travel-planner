// ─── Custom Exceptions ──────────────────────────────────────────────
// Exception classes thrown by datasources, caught by repositories.

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({this.message = 'Server error', this.statusCode});
  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'No network connection'});
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache error'});
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException({this.message = 'Auth error', this.code});
  @override
  String toString() => 'AuthException($code): $message';
}

class AIException implements Exception {
  final String message;
  final String? provider;
  AIException({this.message = 'AI service error', this.provider});
  @override
  String toString() => 'AIException($provider): $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  ValidationException({this.message = 'Validation error', this.fieldErrors});
  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({this.message = 'Resource not found'});
  @override
  String toString() => 'NotFoundException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  RateLimitException({this.message = 'Rate limit exceeded', this.retryAfter});
  @override
  String toString() => 'RateLimitException: $message';
}
