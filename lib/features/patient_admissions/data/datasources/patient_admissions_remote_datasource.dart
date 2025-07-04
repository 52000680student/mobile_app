import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/parameter_constants.dart';
import '../models/patient_models.dart';

abstract class PatientAdmissionsRemoteDataSource {
  Future<List<DepartmentParameter>> getDepartments();
  Future<PatientVisitResponse> getWaitingForAdmission(
      PatientVisitQueryParams params);
  Future<PatientVisitResponse> getSampleTaken(PatientVisitQueryParams params);
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
}
