import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/app_logger.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('🚀 ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info('✅ ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
        '❌ ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.path}: ${err.message}');
    super.onError(err, handler);
  }
}
