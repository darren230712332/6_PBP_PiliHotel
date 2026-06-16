/// Base exception for API-related errors
abstract class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when network error occurs (timeout, connection refused, etc.)
class NetworkException extends ApiException {
  NetworkException(String message) : super('Network Error: $message');
}

/// Exception thrown when server returns an error status code
class ServerException extends ApiException {
  final int? statusCode;
  final Map<String, dynamic>? errorData;

  ServerException(
    String message, {
    this.statusCode,
    this.errorData,
  }) : super('Server Error: $message');
}

/// Exception thrown for authentication failures (401, 403)
class AuthenticationException extends ServerException {
  AuthenticationException(super.message)
      : super(statusCode: 401);
}

/// Exception thrown when requested resource is not found (404)
class NotFoundException extends ServerException {
  NotFoundException(super.message)
      : super(statusCode: 404);
}

/// Exception thrown when validation fails (422)
class ValidationException extends ServerException {
  ValidationException(
    super.message, {
    super.errorData,
  }) : super(statusCode: 422);
}

/// Exception thrown when request timeout occurs
class TimeoutException extends ApiException {
  TimeoutException() : super('Request timeout. Please try again.');
}

/// Exception thrown when parsing JSON response fails
class ParseException extends ApiException {
  ParseException(String message) : super('Parse Error: $message');
}
