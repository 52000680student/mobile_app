import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../constants/app_constants.dart';
import '../../constants/patient_states.dart';
import '../../router/app_router.dart';

class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check for 401 errors across all error types first
    _checkForUnauthorizedError(err);

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
      message: ErrorMessages.connectionTimeoutError,
      response: error.response,
    );
  }

  DioException _createConnectionError(DioException error) {
    _logger.w('Connection error: ${error.requestOptions.path}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: ErrorMessages.networkConnectionError,
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
            _extractErrorMessage(responseData) ?? ErrorMessages.badRequestError;
        break;
      case 401:
        message = ErrorMessages.sessionExpiredError;
        _redirectToLogin();
        break;
      case 403:
        message = ErrorMessages.accessDeniedError;
        break;
      case 404:
        message = ErrorMessages.notFoundError;
        break;
      case 409:
        message = _extractErrorMessage(responseData) ??
            'Conflict. The resource already exists.';
        break;
      case 422:
        message = _extractValidationErrors(responseData) ??
            ErrorMessages.validationFailedError;
        break;
      case 429:
        message = ErrorMessages.tooManyRequestsError;
        break;
      case 500:
        message = ErrorMessages.internalServerError;
        break;
      case 502:
        message = ErrorMessages.serviceUnavailableError;
        break;
      case 503:
        message = ErrorMessages.serviceUnavailableError;
        break;
      default:
        message =
            _extractErrorMessage(responseData) ?? ErrorMessages.serverError;
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
      message: ErrorMessages.requestCancelledError,
      response: error.response,
    );
  }

  DioException _createUnknownError(DioException error) {
    _logger.e('Unknown error: ${error.message}');

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      message: ErrorMessages.unexpectedError,
      response: error.response,
    );
  }

  void _redirectToLogin() {
    // Use GoRouter directly to navigate to login
    try {
      AppRouter.router.go(AppRoutes.login);
    } catch (e) {
      _logger.w('Could not redirect to login: $e');
    }
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

  /// Check for 401 errors regardless of the DioException type
  void _checkForUnauthorizedError(DioException error) {
    final statusCode = error.response?.statusCode;

    // Direct status code check
    if (statusCode == 401) {
      _redirectToLogin();
      return;
    }

    // Check for auth-related error messages in response data
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errorMessage = _extractErrorMessage(responseData)?.toLowerCase();
      if (errorMessage != null &&
          (errorMessage.contains('unauthorized') ||
              errorMessage.contains('token') ||
              errorMessage.contains('session') ||
              errorMessage.contains('expired'))) {
        _redirectToLogin();
        return;
      }
    }

    // Check for authorization errors in headers
    final headers = error.response?.headers;
    if (headers != null) {
      final authHeader = headers['www-authenticate'];
      if (authHeader != null && authHeader.isNotEmpty) {
        _redirectToLogin();
        return;
      }
    }
  }
}
