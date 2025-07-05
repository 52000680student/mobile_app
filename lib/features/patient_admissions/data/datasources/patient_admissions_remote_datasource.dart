import 'package:injectable/injectable.dart';
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
    } catch (e) {
      throw Exception('Failed to fetch departments: $e');
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
    } catch (e) {
      throw Exception('Failed to fetch waiting for admission patients: $e');
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
    } catch (e) {
      throw Exception('Failed to fetch sample taken patients: $e');
    }
  }

  @override
  Future<SampleResponse> getRequestSamples(int requestId) async {
    try {
      AppLogger.debug(
          'Making API call to: ${ApiParameters.getRequestSamplesUrl(requestId)}');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiParameters.getRequestSamplesUrl(requestId),
      );

      AppLogger.debug('API Response status: ${response.statusCode}');
      AppLogger.debug('API Response data: ${response.data}');

      if (response.data != null) {
        AppLogger.debug('Parsing SampleResponse from JSON...');
        final sampleResponse = SampleResponse.fromJson(response.data!);
        AppLogger.debug(
            'Successfully parsed ${sampleResponse.samples.length} samples');
        return sampleResponse;
      }

      throw Exception('No sample data received');
    } catch (e) {
      AppLogger.error('Error in getRequestSamples: $e');
      throw Exception('Failed to fetch request samples: $e');
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
    } catch (e) {
      throw Exception('Failed to fetch request tests: $e');
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
    } catch (e) {
      throw Exception('Failed to fetch test details: $e');
    }
  }

  @override
  Future<void> updateSample(
      int requestId, Map<String, dynamic> sampleData) async {
    try {
      AppLogger.debug(
          'Making API call to: ${ApiParameters.getRequestSamplesUrl(requestId)}');

      final response = await _apiClient.put<void>(
        ApiParameters.getRequestSamplesUrl(requestId),
        data: sampleData,
      );

      AppLogger.debug('API Response status: ${response.statusCode}');
      AppLogger.debug('Sample updated successfully');
    } catch (e) {
      AppLogger.error('Error in updateSample: $e');
      throw Exception('Failed to update sample data: $e');
    }
  }

  @override
  Future<void> takeAllSamples(int requestId, String collectorUserId) async {
    try {
      AppLogger.debug('Taking all samples for request ID: $requestId');

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
      final response = await _apiClient.put<void>(
        ApiParameters.getRequestSamplesUrl(requestId),
        data: sampleData,
      );

      AppLogger.debug('API Response status: ${response.statusCode}');
      AppLogger.debug('All samples taken successfully');
    } catch (e) {
      AppLogger.error('Error in takeAllSamples: $e');
      throw Exception('Failed to take all samples: $e');
    }
  }
}
