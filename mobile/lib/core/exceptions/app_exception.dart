// Base exception
class AppException implements Exception {
  final String message;
  final String? code;
  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException${code != null ? '[$code]' : ''}: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class TimeoutAppException extends AppException {
  TimeoutAppException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.code});
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  ValidationException(super.message, {super.code, this.fieldErrors});
}
