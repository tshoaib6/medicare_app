class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([String message = 'Network error occurred'])
      : super(message);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Server error occurred'])
      : super(message);
}

class AuthenticationException extends ApiException {
  const AuthenticationException([String message = 'Authentication failed'])
      : super(message, statusCode: 401);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException(String message, {this.errors, int? statusCode})
      : super(message, statusCode: statusCode);

  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final firstKey = errors!.keys.first;
      final firstErrorList = errors![firstKey];
      if (firstErrorList != null && firstErrorList.isNotEmpty) {
        return firstErrorList.first;
      }
    }
    return message;
  }
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, statusCode: 404);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Access forbidden'])
      : super(message, statusCode: 403);
}

class TimeoutException extends ApiException {
  const TimeoutException([String message = 'Request timeout']) : super(message);
}
