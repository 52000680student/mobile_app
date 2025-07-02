import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/app_logger.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    AppLogger.info('📍 Full URL: ${options.uri}');
    AppLogger.info('📋 Headers: ${options.headers}');
    AppLogger.info('🔧 Content-Type: ${options.contentType}');

    // Log request data with special handling for form data
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        AppLogger.info('📝 Form Data Fields:');
        for (final field in formData.fields) {
          final key = field.key;
          final value =
              key.toLowerCase().contains('password') ? '*****' : field.value;
          AppLogger.info('  - $key: $value');
        }
        if (formData.files.isNotEmpty) {
          AppLogger.info('📎 Form Data Files:');
          for (final file in formData.files) {
            AppLogger.info('  - ${file.key}: ${file.value.filename}');
          }
        }
      } else if (options.data is Map) {
        final dataMap = options.data as Map;
        final sanitizedData = dataMap.map((key, value) => MapEntry(
            key,
            key.toString().toLowerCase().contains('password')
                ? '*****'
                : value));
        AppLogger.info('📝 Request Data (Map): $sanitizedData');
      } else {
        AppLogger.info('📝 Request Data: ${options.data}');
      }
    }

    if (options.queryParameters.isNotEmpty) {
      AppLogger.info('🔍 Query Parameters: ${options.queryParameters}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    AppLogger.info('📄 Response Headers: ${response.headers.map}');

    // Log response data (be careful with sensitive data)
    if (response.data != null) {
      String responseDataStr;
      if (response.data is Map &&
          (response.data as Map).containsKey('access_token')) {
        // Don't log sensitive token data
        responseDataStr = 'Contains access_token (hidden for security)';
      } else {
        responseDataStr = response.data.toString();
        // Limit response data length for readability
        if (responseDataStr.length > 500) {
          responseDataStr =
              '${responseDataStr.substring(0, 500)}... (truncated)';
        }
      }
      AppLogger.info('📋 Response Data: $responseDataStr');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    AppLogger.error('🚨 Error Type: ${err.type}');
    AppLogger.error('💬 Error Message: ${err.message}');

    if (err.response != null) {
      AppLogger.error(
          '📄 Error Response Headers: ${err.response?.headers.map}');
      AppLogger.error('📋 Error Response Data: ${err.response?.data}');
    }

    // Log the full request details for debugging
    AppLogger.error('🔍 Failed Request Details:');
    AppLogger.error('  - Method: ${err.requestOptions.method}');
    AppLogger.error('  - URL: ${err.requestOptions.uri}');
    AppLogger.error('  - Headers: ${err.requestOptions.headers}');
    AppLogger.error('  - Content-Type: ${err.requestOptions.contentType}');

    if (err.requestOptions.data != null) {
      if (err.requestOptions.data is FormData) {
        final formData = err.requestOptions.data as FormData;
        AppLogger.error('  - Form Data Fields:');
        for (final field in formData.fields) {
          final key = field.key;
          final value =
              key.toLowerCase().contains('password') ? '*****' : field.value;
          AppLogger.error('    * $key: $value');
        }
      } else {
        AppLogger.error('  - Data: ${err.requestOptions.data}');
      }
    }

    super.onError(err, handler);
  }
}
