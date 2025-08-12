import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/constants/parameter_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/manual_service_models.dart';
import '../../../patient_admissions/data/models/patient_models.dart'; // Added for SampleResponse

abstract class ManualServiceRemoteDataSource {
  /// Search patients by query
  Future<PatientSearchResponse> searchPatients(PatientSearchQueryParams params);

  /// Get departments list
  Future<DepartmentResponse> getDepartments(DepartmentQueryParams params);

  /// Get service parameters (L125 codes)
  Future<List<ServiceParameter>> getServiceParameters();

  /// Get test services
  Future<TestServiceResponse> getTestServices(TestServiceQueryParams params);

  /// Get doctors list
  Future<DoctorResponse> getDoctors(DoctorQueryParams params);

  /// Save manual service request
  Future<ManualServiceRequestResponse> saveManualServiceRequest(
      ManualServiceRequest request);

  /// Get request samples for barcode generation
  Future<SampleResponse> getRequestSamples(int requestId);

  /// Generate barcode from print API
  Future<BarcodePrintResponse> generateBarcode(BarcodePrintRequest request);

  /// Download barcode PDF as bytes from report URL
  Future<List<int>> downloadBarcodePdf(String reportUrl);
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
      final queryParams = params.toQueryParameters();
      AppLogger.info('Searching patients with params: $queryParams');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/pt/v1/individuals/patients/patientId',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final patientResponse =
            PatientSearchResponse.fromJson(response.data!, params.search ?? "");
        return patientResponse;
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
        '/api/ms/v1/parameters/${ParameterConstants.departmentParameterCode}/codes',
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

  @override
  Future<DoctorResponse> getDoctors(DoctorQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/pt/v1/individuals/patients',
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return DoctorResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return DoctorResponse(
        data: [],
        page: 1,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
      AppLogger.error('DioException in getDoctors: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while fetching doctors',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while fetching doctors',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to fetch doctors',
        );
      }
    } catch (e) {
      AppLogger.error('Error in getDoctors: $e');
      rethrow;
    }
  }

  @override
  Future<ManualServiceRequestResponse> saveManualServiceRequest(
      ManualServiceRequest request) async {
    try {
      AppLogger.info(
          'Saving manual service request with data: ${request.toJson()}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/la/v1/requests',
        data: request.toJson(),
      );

      AppLogger.info(
          'Manual service request response status: ${response.statusCode}');
      AppLogger.info('Manual service request response data: ${response.data}');

      if (response.data != null) {
        final requestResponse =
            ManualServiceRequestResponse.fromJson(response.data!);
        AppLogger.info(
            'Successfully saved manual service request with ID: ${requestResponse.id}');
        return requestResponse;
      }

      AppLogger.error('Manual service request returned null data');
      throw const ServerException(message: 'Invalid response from server');
    } on DioException catch (e) {
      AppLogger.error('DioException in saveManualServiceRequest: ${e.message}');
      AppLogger.error('DioException type: ${e.type}');
      AppLogger.error('DioException response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while saving manual service request',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while saving manual service request',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to save manual service request',
        );
      }
    } catch (e) {
      AppLogger.error('Error in saveManualServiceRequest: $e');
      rethrow;
    }
  }

  @override
  Future<SampleResponse> getRequestSamples(int requestId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/la/v1/requests/$requestId/samples',
      );

      if (response.data != null) {
        final sampleResponse = SampleResponse.fromJson(response.data!);
        AppLogger.info(
            'Successfully fetched ${sampleResponse.samples.length} samples for request $requestId');
        return sampleResponse;
      }

      throw const ServerException(message: 'No sample data received');
    } on DioException catch (e) {
      AppLogger.error('DioException in getRequestSamples: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while fetching request samples',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while fetching request samples',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to fetch request samples',
        );
      }
    } catch (e) {
      AppLogger.error('Error in getRequestSamples: $e');
      rethrow;
    }
  }

  @override
  Future<BarcodePrintResponse> generateBarcode(
      BarcodePrintRequest request) async {
    try {
      final queryParams = request.toQueryParameters();
      AppLogger.info('Generating barcode with params: $queryParams');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/la/v1/global/reports/101/print',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final barcodeResponse = BarcodePrintResponse.fromJson(response.data!);
        AppLogger.info(
            'Successfully generated barcode with UUID: ${barcodeResponse.reportUUID}');
        return barcodeResponse;
      }

      throw const ServerException(message: 'No barcode data received');
    } on DioException catch (e) {
      AppLogger.error('DioException in generateBarcode: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while generating barcode',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while generating barcode',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to generate barcode',
        );
      }
    } catch (e) {
      AppLogger.error('Error in generateBarcode: $e');
      rethrow;
    }
  }

  @override
  Future<List<int>> downloadBarcodePdf(String reportUrl) async {
    try {
      AppLogger.info('Downloading barcode PDF from: $reportUrl');

      final response = await _apiClient.get<List<int>>(
        reportUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data != null) {
        AppLogger.info(
            'Successfully downloaded barcode PDF, size: ${response.data!.length} bytes');
        return response.data!;
      }

      throw const ServerException(message: 'No barcode PDF data received');
    } on DioException catch (e) {
      AppLogger.error('DioException in downloadBarcodePdf: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          message: 'Connection timeout while downloading barcode PDF',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Connection error while downloading barcode PDF',
        );
      } else {
        throw NetworkException(
          message: e.message ?? 'Failed to download barcode PDF',
        );
      }
    } catch (e) {
      AppLogger.error('Error in downloadBarcodePdf: $e');
      rethrow;
    }
  }
}
