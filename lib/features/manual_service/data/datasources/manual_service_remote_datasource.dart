import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/manual_service_models.dart';

abstract class ManualServiceRemoteDataSource {
  /// Search patients by query
  Future<PatientSearchResponse> searchPatients(PatientSearchQueryParams params);

  /// Get departments list
  Future<DepartmentResponse> getDepartments(DepartmentQueryParams params);

  /// Get service parameters (L125 codes)
  Future<List<ServiceParameter>> getServiceParameters();

  /// Get test services
  Future<TestServiceResponse> getTestServices(TestServiceQueryParams params);
}

@LazySingleton(as: ManualServiceRemoteDataSource)
class ManualServiceRemoteDataSourceImpl
    implements ManualServiceRemoteDataSource {
  final ApiClient _apiClient;

  ManualServiceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PatientSearchResponse> searchPatients(
      PatientSearchQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/pt/v1/individuals/patients/patientId',
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return PatientSearchResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return PatientSearchResponse(
        data: [],
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in searchPatients: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while searching patients',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while searching patients',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to search patients',
        );
      }
    } catch (e) {
      AppLogger.error('Error in searchPatients: $e');
      rethrow;
    }
  }

  @override
  Future<DepartmentResponse> getDepartments(
      DepartmentQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/ms/v1/departments',
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return DepartmentResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return DepartmentResponse(
        data: [],
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getDepartments: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while fetching departments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while fetching departments',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to fetch departments',
        );
      }
    } catch (e) {
      AppLogger.error('Error in getDepartments: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceParameter>> getServiceParameters() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/api/ms/v1/parameters/L125/codes',
      );

      if (response.data != null) {
        return (response.data as List)
            .map((json) =>
                ServiceParameter.fromJson(json as Map<String, dynamic>))
            .where((param) =>
                param.inUse) // Only return parameters that are in use
            .toList();
      }

      return [];
    } on DioException catch (e) {
      AppLogger.error('DioException in getServiceParameters: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while fetching service parameters',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while fetching service parameters',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to fetch service parameters',
        );
      }
    } catch (e) {
      AppLogger.error('Error in getServiceParameters: $e');
      rethrow;
    }
  }

  @override
  Future<TestServiceResponse> getTestServices(
      TestServiceQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/la/v1/tests',
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return TestServiceResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return TestServiceResponse(
        data: [],
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getTestServices: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while fetching test services',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while fetching test services',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to fetch test services',
        );
      }
    } catch (e) {
      AppLogger.error('Error in getTestServices: $e');
      rethrow;
    }
  }
}
