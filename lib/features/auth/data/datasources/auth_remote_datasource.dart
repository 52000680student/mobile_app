import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/env/env_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/auth_response_model.dart';
import '../../domain/entities/login_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest loginRequest);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequest loginRequest) async {
    try {
      AppLogger.info('🔐 Starting login request...');
      AppLogger.info('👤 Username: ${loginRequest.username}');
      AppLogger.info('🔑 Grant Type: ${loginRequest.grantType}');

      // Use the specific login endpoint
      final loginUrl = '${EnvConfig.apiBaseUrl}/connect/token';
      AppLogger.info('🌐 Login URL: $loginUrl');

      // Create form data as Map<String, dynamic> for proper form encoding
      final formData = <String, dynamic>{
        'username': loginRequest.username,
        'password': loginRequest.password,
        'grant_type': loginRequest.grantType,
        'scope': '',
      };

      AppLogger.info(
          '📝 Form Data: ${formData.map((key, value) => MapEntry(key, key == 'password' ? '*****' : value))}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        loginUrl,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic ${EnvConfig.keyLogin}',
          },
          followRedirects: false,
          validateStatus: (status) {
            AppLogger.info('📊 Response Status: $status');
            return status != null &&
                status <
                    500; // Don't throw for 4xx errors, handle them manually
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('🎉 Login successful!');
        return AuthResponseModel.fromJson(response.data!);
      } else if (response.statusCode == 400) {
        final errorData = response.data;
        AppLogger.info('🔍 Error Data: $errorData');
        String errorMessage = 'Invalid credentials';

        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('error_description')) {
            errorMessage = errorData['error_description'] as String;
          } else if (errorData.containsKey('error')) {
            final error = errorData['error'] as String;
            switch (error) {
              case 'invalid_request':
                errorMessage = 'Invalid request format or missing parameters';
                break;
              case 'invalid_client':
                errorMessage = 'Invalid client credentials';
                break;
              case 'invalid_grant':
                errorMessage = 'Invalid username or password';
                break;
              case 'unsupported_grant_type':
                errorMessage = 'Unsupported grant type';
                break;
              default:
                errorMessage = 'Authentication failed: $error';
            }
          }
        }

        AppLogger.error('❌ Login failed (400): $errorMessage');
        throw ServerException(
          message: errorMessage,
          statusCode: 400,
        );
      } else if (response.statusCode == 401) {
        AppLogger.error('❌ Login failed (401): Unauthorized');
        throw ServerException(
          message: 'Invalid username or password',
          statusCode: 401,
        );
      } else {
        AppLogger.error(
            '❌ Login failed (${response.statusCode}): Unexpected response');
        throw ServerException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('🚨 DioException occurred', e);
      AppLogger.error('🔍 Request options: ${e.requestOptions.toString()}');
      AppLogger.error('🔍 Request data: ${e.requestOptions.data}');
      AppLogger.error('🔍 Request headers: ${e.requestOptions.headers}');

      if (e.response != null) {
        AppLogger.error('🔍 Response status: ${e.response?.statusCode}');
        AppLogger.error('🔍 Response data: ${e.response?.data}');
        AppLogger.error('🔍 Response headers: ${e.response?.headers.map}');
      }

      if (e.response?.statusCode == 400) {
        // Extract more specific error information
        final responseData = e.response?.data;
        String errorMessage = 'Invalid request format or missing parameters';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error_description')) {
            errorMessage = responseData['error_description'] as String;
          } else if (responseData.containsKey('error')) {
            errorMessage = 'Authentication error: ${responseData['error']}';
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        throw ServerException(
          message: errorMessage,
          statusCode: 400,
        );
      } else if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Invalid username or password',
          statusCode: 401,
        );
      } else {
        throw NetworkException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('💥 Unexpected error during login', e);
      throw UnknownException(message: 'Login failed: ${e.toString()}');
    }
  }
}
