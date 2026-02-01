sealed class APIException implements Exception {
  APIException(this.message);
  final String message;
}

class InvalidApiKeyException extends APIException {
  InvalidApiKeyException() : super('Invalid API key');
}

class NoInternetConnectionException extends APIException {
  NoInternetConnectionException() : super('No Internet connection');
}

class NoDataFoundException extends APIException {
  NoDataFoundException() : super('No data found');
}

class UnknownException extends APIException {
  UnknownException() : super('Some error occurred');
}

class BadRequestException extends APIException {
  BadRequestException(message)
      : super(message ?? 'Invalid input request parameters');
}

class ConflictException extends APIException {
  ConflictException(message) : super(message ?? 'Conflict error occured');
}

class DuplicateException extends APIException {
  DuplicateException(message) : super(message ?? 'Duplicate error occured');
}
