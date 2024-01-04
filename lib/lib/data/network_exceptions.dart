import 'dart:io';

import 'package:dio/dio.dart';

class NetworkExceptions {
  final String message;

  NetworkExceptions(this.message);

  static NetworkExceptions requestCancelled =
      NetworkExceptions("Request Cancelled");
  static NetworkExceptions unauthorisedRequest =
      NetworkExceptions("Unauthorised request");
  static NetworkExceptions badRequest = NetworkExceptions("Bad request");
  static NetworkExceptions notFound(String reason) => NetworkExceptions(reason);
  static NetworkExceptions methodNotAllowed =
      NetworkExceptions("Method Allowed");
  static NetworkExceptions notAcceptable = NetworkExceptions("Not acceptable");
  static NetworkExceptions requestTimeout =
      NetworkExceptions("Connection request timeout");
  static NetworkExceptions sendTimeout =
      NetworkExceptions("Send timeout in connection with API server");
  static NetworkExceptions conflict =
      NetworkExceptions("Error due to a conflict");
  static NetworkExceptions internalServerError =
      NetworkExceptions("Internal Server Error");
  static NetworkExceptions notImplemented =
      NetworkExceptions("Not Implemented");
  static NetworkExceptions serviceUnavailable =
      NetworkExceptions("Service unavailable");
  static NetworkExceptions noInternetConnection =
      NetworkExceptions("No internet connection");
  static NetworkExceptions formatException =
      NetworkExceptions("Unexpected error occurred");
  static NetworkExceptions unableToProcess =
      NetworkExceptions("Unable to process the data");
  static NetworkExceptions unexpectedError =
      NetworkExceptions("Unexpected error occurred");
  static NetworkExceptions defaultError(String error) =>
      NetworkExceptions(error);

  // Create a factory constructor to get DioException
  factory NetworkExceptions.fromDioException(dynamic error) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              return requestCancelled;
            case DioExceptionType.connectionTimeout:
              return requestTimeout;
            case DioExceptionType.connectionError:
              return noInternetConnection;
            case DioExceptionType.receiveTimeout:
              return sendTimeout;
            case DioExceptionType.unknown:
              switch (error.response?.statusCode) {
                case 400:
                case 401:
                case 403:
                  return unauthorisedRequest;
                case 404:
                  return notFound("Not found");
                case 409:
                  return conflict;
                case 408:
                  return requestTimeout;
                case 500:
                  return internalServerError;
                case 503:
                  return serviceUnavailable;
                default:
                  if (error is SocketException) {
                    return noInternetConnection;
                  } else {
                    return unexpectedError;
                  }
              }
            case DioExceptionType.sendTimeout:
              return sendTimeout;
            case DioExceptionType.badCertificate:
              return badRequest;
            case DioExceptionType.badResponse:
              return internalServerError;
          }
        }
      } on FormatException catch (_) {
        return formatException;
      } catch (_) {
        return unexpectedError;
      }
    } else if (error is SocketException) {
      return noInternetConnection;
    }
    if (error.toString().contains("is not a subtype of")) {
      return unableToProcess;
    } else {
      return unexpectedError;
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    return networkExceptions.message;
  }
}
