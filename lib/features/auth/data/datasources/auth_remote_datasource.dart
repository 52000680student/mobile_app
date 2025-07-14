import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/env/env_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/patient_states.dart';
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
      // Use the specific login endpoint
      final loginUrl = '${EnvConfig.apiAuthBaseUrl}/connect/token';

      // Create form data as Map<String, dynamic> for proper form encoding
      final formData = <String, dynamic>{
        'username': loginRequest.username,
        'password': loginRequest.password,
        'grant_type': loginRequest.grantType,
        'scope': '',
      };

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
            return status != null &&
                status <
                    500; // Don't throw for 4xx errors, handle them manually
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponseModel.fromJson(response.data!);
      } else if (response.statusCode == 400) {
        final errorData = response.data;
        String errorMessage = ErrorMessages.invalidUsernameOrPassword;

        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('error_description')) {
            final description = errorData['error_description'] as String;
            if (description.toLowerCase().contains('invalid') ||
                description.toLowerCase().contains('credentials') ||
                description.toLowerCase().contains('username') ||
                description.toLowerCase().contains('password')) {
              errorMessage = ErrorMessages.invalidUsernameOrPassword;
            } else {
              errorMessage = description;
            }
          } else if (errorData.containsKey('error')) {
            final error = errorData['error'] as String;
            switch (error) {
              case 'invalid_request':
                errorMessage = ErrorMessages.invalidRequest;
                break;
              case 'invalid_client':
                errorMessage = ErrorMessages.authenticationServiceError;
                break;
              case 'invalid_grant':
                errorMessage = ErrorMessages.invalidUsernameOrPassword;
                break;
              case 'unsupported_grant_type':
                errorMessage = ErrorMessages.authenticationServiceError;
                break;
              default:
                errorMessage = ErrorMessages.invalidUsernameOrPassword;
            }
          }
        }

        throw ServerException(
          message: errorMessage,
          statusCode: 400,
        );
      } else if (response.statusCode == 401) {
        throw const ServerException(
          message: ErrorMessages.invalidUsernameOrPassword,
          statusCode: 401,
        );
      } else {
        throw ServerException(
          message: ErrorMessages.authenticationServiceError,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Handle network-related errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: ErrorMessages.connectionTimeout,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: ErrorMessages.networkError,
        );
      } else if (e.response?.statusCode == 400) {
        // Handle 400 status - incorrect password or account for login
        final responseData = e.response?.data;
        String errorMessage = ErrorMessages.invalidUsernameOrPassword;

        if (responseData is Map<String, dynamic>) {
          // Prioritize 'title' field from server response
          if (responseData.containsKey('title')) {
            final title = responseData['title'] as String?;
            if (title != null && title.isNotEmpty) {
              errorMessage = title;
            }
          } else if (responseData.containsKey('error_description')) {
            final description = responseData['error_description'] as String;
            if (description.toLowerCase().contains('invalid') ||
                description.toLowerCase().contains('credentials') ||
                description.toLowerCase().contains('username') ||
                description.toLowerCase().contains('password')) {
              errorMessage = ErrorMessages.invalidUsernameOrPassword;
            } else {
              errorMessage = description;
            }
          } else if (responseData.containsKey('error')) {
            final error = responseData['error'] as String;
            if (error == 'invalid_grant' || error == 'invalid_client') {
              errorMessage = ErrorMessages.invalidUsernameOrPassword;
            } else {
              errorMessage = ErrorMessages.authenticationFailed;
            }
          }
        }

        throw ServerException(
          message: errorMessage,
          statusCode: 400,
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 status - server problem for login
        final responseData = e.response?.data;
        String errorMessage = ErrorMessages.internalServerError;

        if (responseData is Map<String, dynamic>) {
          // Prioritize 'title' field from server response
          if (responseData.containsKey('title')) {
            final title = responseData['title'] as String?;
            if (title != null && title.isNotEmpty) {
              errorMessage = title;
            }
          }
        }

        throw ServerException(
          message: errorMessage,
          statusCode: 500,
        );
      } else if (e.response?.statusCode == 401) {
        throw const ServerException(
          message: ErrorMessages.invalidUsernameOrPassword,
          statusCode: 401,
        );
      } else {
        throw NetworkException(
          message: ErrorMessages.networkError,
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error during login', e);
      throw UnknownException(
        message: ErrorMessages.anUnexpectedErrorOccurred,
      );
    }
  }
}
