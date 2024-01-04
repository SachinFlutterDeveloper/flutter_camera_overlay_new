class AppExceptions implements Exception {
  final _message;

  final _prefix;

  AppExceptions([this._message, this._prefix]);

  @override
  String toString() {
    return (_message != null) ? '$_prefix: $_message' : '$_prefix';
  }
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? prefix, String? message])
      : super(message, 'Error during communication');
}

class NoInternetException extends AppExceptions {
  NoInternetException([String? prefix, String? message])
      : super('Please check your internet connection');
}

class BadRequestException extends AppExceptions {
  BadRequestException([String? prefix, String? message])
      : super(message, 'Invalid request');
}

class NotFoundException extends AppExceptions {
  NotFoundException([String? prefix, String? message])
      : super(message, 'Service Not Found');
}

class UnauthorisedException extends AppExceptions {
  UnauthorisedException([String? prefix, String? message])
      : super('Your current session expired please login again',
            'Unauthorized Request');
}

class InvalidInputException extends AppExceptions {
  InvalidInputException([String? prefix, String? message])
      : super(message, 'Invalid input');
}

class InternalServerException extends AppExceptions {
  InternalServerException([String? prefix, String? message])
      : super(message, 'Internal Server Error');
}
