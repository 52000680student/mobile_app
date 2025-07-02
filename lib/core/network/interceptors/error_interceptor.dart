import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final modifiedError = _handleError(err);
    handler.next(modifiedError);
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _createTimeoutError(error);

      case DioExceptionType.connectionError:
        return _createConnectionError(error);

      case DioExceptionType.badResponse:
        return _createResponseError(error);

      case DioExceptionType.cancel:
        return _createCancelError(error);

      case DioExceptionType.unknown:
      default:
        return _createUnknownError(error);
    }
  }

  DioException _createTimeoutError(DioException error) {
    _logger.w('Request timeout: ${error.requestOptions.path}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: 'Connection timeout. Please check your internet connection.',
      response: error.response,
    );
  }

  DioException _createConnectionError(DioException error) {
    _logger.w('Connection error: ${error.requestOptions.path}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: 'No internet connection. Please check your network settings.',
      response: error.response,
    );
  }

  DioException _createResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message;

    switch (statusCode) {
      case 400:
        message =
            _extractErrorMessage(responseData) ??
            'Bad request. Please check your input.';
        break;
      case 401:
        message = 'Authentication failed. Please login again.';
        break;
      case 403:
        message =
            'Access denied. You don\'t have permission to perform this action.';
        break;
      case 404:
        message = 'Resource not found.';
        break;
      case 409:
        message =
            _extractErrorMessage(responseData) ??
            'Conflict. The resource already exists.';
        break;
      case 422:
        message =
            _extractValidationErrors(responseData) ?? 'Validation failed.';
        break;
      case 429:
        message = 'Too many requests. Please try again later.';
        break;
      case 500:
        message = 'Internal server error. Please try again later.';
        break;
      case 502:
        message = 'Service temporarily unavailable.';
        break;
      case 503:
        message = 'Service temporarily unavailable.';
        break;
      default:
        message =
            _extractErrorMessage(responseData) ?? 'Server error occurred.';
    }

    _logger.e('HTTP Error [$statusCode]: $message');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: message,
      response: error.response,
    );
  }

  DioException _createCancelError(DioException error) {
    _logger.i('Request cancelled: ${error.requestOptions.path}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: 'Request was cancelled.',
      response: error.response,
    );
  }

  DioException _createUnknownError(DioException error) {
    _logger.e('Unknown error: ${error.message}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: 'An unexpected error occurred. Please try again.',
      response: error.response,
    );
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      // Try different common error message keys
      for (final key in ['message', 'error', 'detail', 'description']) {
        if (responseData.containsKey(key) && responseData[key] is String) {
          return responseData[key] as String;
        }
      }
    }

    return null;
  }

  String? _extractValidationErrors(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      // Handle Laravel-style validation errors
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];

        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          } else if (messages is String) {
            errorMessages.add(messages);
          }
        });

        if (errorMessages.isNotEmpty) {
          return errorMessages.join('\n');
        }
      }

      // Handle other validation error formats
      return _extractErrorMessage(responseData);
    }

    return null;
  }
}
