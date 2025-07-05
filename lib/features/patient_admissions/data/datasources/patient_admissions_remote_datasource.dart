import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/constants/patient_states.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/parameter_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/patient_models.dart';

abstract class PatientAdmissionsRemoteDataSource {
  Future<List<DepartmentParameter>> getDepartments();
  Future<PatientVisitResponse> getWaitingForAdmission(
      PatientVisitQueryParams params);
  Future<PatientVisitResponse> getSampleTaken(PatientVisitQueryParams params);

  // New methods for sample and test operations
  Future<SampleResponse> getRequestSamples(int requestId);
  Future<List<Test>> getRequestTests(int requestId);
  Future<TestDetails> getTestByCode(String testCode, String effectiveTime);

  // Method to update sample data
  Future<void> updateSample(int requestId, Map<String, dynamic> sampleData);

  // Method to take all samples (set all collectorUserId)
  Future<void> takeAllSamples(int requestId, String collectorUserId);
}

@LazySingleton(as: PatientAdmissionsRemoteDataSource)
class PatientAdmissionsRemoteDataSourceImpl
    implements PatientAdmissionsRemoteDataSource {
  final ApiClient _apiClient;

  PatientAdmissionsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<DepartmentParameter>> getDepartments() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiParameters.getDepartmentCodesUrl(
            ParameterConstants.departmentParameterCode),
      );

      if (response.data != null) {
        return (response.data as List)
            .map((json) =>
                DepartmentParameter.fromJson(json as Map<String, dynamic>))
            .where(
                (dept) => dept.inUse) // Only return departments that are in use
            .toList();
      }

      return [];
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getDepartments: $e');
      rethrow;
    }
  }

  @override
  Future<PatientVisitResponse> getWaitingForAdmission(
      PatientVisitQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ParameterConstants.waitingForAdmissionEndpoint,
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return PatientVisitResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return PatientVisitResponse(
        data: [],
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getWaitingForAdmission: $e');
      rethrow;
    }
  }

  @override
  Future<PatientVisitResponse> getSampleTaken(
      PatientVisitQueryParams params) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ParameterConstants.sampleTakenEndpoint,
        queryParameters: params.toQueryParameters(),
      );

      if (response.data != null) {
        return PatientVisitResponse.fromJson(response.data!);
      }

      // Return empty response if no data
      return PatientVisitResponse(
        data: [],
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getSampleTaken: $e');
      rethrow;
    }
  }

  @override
  Future<SampleResponse> getRequestSamples(int requestId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiParameters.getRequestSamplesUrl(requestId),
      );

      if (response.data != null) {
        final sampleResponse = SampleResponse.fromJson(response.data!);
        return sampleResponse;
      }

      throw Exception('No sample data received');
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getRequestSamples: $e');
      rethrow;
    }
  }

  @override
  Future<List<Test>> getRequestTests(int requestId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiParameters.getRequestTestsUrl(requestId),
      );

      if (response.data != null) {
        return (response.data as List)
            .map((json) => Test.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getRequestTests: $e');
      rethrow;
    }
  }

  @override
  Future<TestDetails> getTestByCode(
      String testCode, String effectiveTime) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiParameters.getTestByCodeUrl(testCode, effectiveTime),
      );

      if (response.data != null) {
        return TestDetails.fromJson(response.data!);
      }

      throw Exception('No test details received');
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in getTestByCode: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSample(
      int requestId, Map<String, dynamic> sampleData) async {
    try {
      final response = await _apiClient.putWithTimeout<void>(
        ApiParameters.getRequestSamplesUrl(requestId),
        data: sampleData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update sample');
      }
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in updateSample: $e');
      rethrow;
    }
  }

  @override
  Future<void> takeAllSamples(int requestId, String collectorUserId) async {
    try {
      // First, get the current samples
      final samplesResponse = await getRequestSamples(requestId);

      // Build the sample data with all samples having collectorUserId set
      final sampleData = {
        "id": requestId,
        "isCollected": true,
        "isReceived": false,
        "samples": samplesResponse.samples
            .map((sample) => {
                  "sampleType": sample.sampleType,
                  "sampleColor": sample.sampleColor,
                  "numberOfLabels": sample.numberOfLabels.toString(),
                  "collectionTime": sample.collectionTime,
                  "quality": sample.quality ?? "G",
                  "collectorUserId":
                      collectorUserId, // Set all samples to have this collectorUserId
                  "receivedTime": sample.receivedTime,
                  "receiverUserId": sample.receiverUserId,
                  "sID": sample.sid,
                  "subSID": sample.subSID,
                })
            .toList(),
        "isManual": false,
      };

      // Call the same update API
      final response = await _apiClient.putWithTimeout<void>(
        ApiParameters.getRequestSamplesUrl(requestId),
        data: sampleData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to take all samples');
      }
    } on DioException catch (e) {
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
      } else {
        // Handle all other DioException types
        throw NetworkException(
          message: e.message ?? ErrorMessages.serverError,
        );
      }
    } catch (e) {
      AppLogger.error('Error in takeAllSamples: $e');
      rethrow;
    }
  }
}
