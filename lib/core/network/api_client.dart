import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../env/env_config.dart';
import '../error/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

@singleton
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(_createBaseOptions());
    _setupInterceptors();
  }

  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      sendTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  void _setupInterceptors() {
    if (EnvConfig.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in GET request: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in POST request: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in PUT request: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  // PUT request with custom timeout for long-running operations
  Future<Response<T>> putWithTimeout<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    int? timeoutMs,
  }) async {
    try {
      final customOptions = Options(
        sendTimeout:
            Duration(milliseconds: timeoutMs ?? EnvConfig.longOperationTimeout),
        receiveTimeout:
            Duration(milliseconds: timeoutMs ?? EnvConfig.longOperationTimeout),
      );

      // Merge with existing options if provided
      if (options != null) {
        customOptions.headers = {
          ...?options.headers,
          ...?customOptions.headers
        };
        customOptions.responseType =
            options.responseType ?? customOptions.responseType;
        customOptions.contentType =
            options.contentType ?? customOptions.contentType;
      }

      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: customOptions,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in PUT request with timeout: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in DELETE request: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in PATCH request: $e');
      throw const UnknownException(message: 'Unexpected error occurred');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException(message: 'Connection error');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        return ServerException(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request cancelled');

      case DioExceptionType.unknown:
      default:
        return const UnknownException(message: 'Unknown error occurred');
    }
  }

  // Get the underlying Dio instance for advanced usage
  Dio get dio => _dio;
}
