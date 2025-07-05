import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';

abstract class PatientAdmissionsRepository {
  Future<Either<Failure, List<DepartmentParameter>>> getDepartments();
  Future<Either<Failure, PatientVisitResponse>> getWaitingForAdmission(
      PatientVisitQueryParams params);
  Future<Either<Failure, PatientVisitResponse>> getSampleTaken(
      PatientVisitQueryParams params);

  // New methods for samples and tests
  Future<Either<Failure, SampleResponse>> getRequestSamples(int requestId);
  Future<Either<Failure, List<Test>>> getRequestTests(int requestId);
  Future<Either<Failure, TestDetails>> getTestByCode(
      String testCode, String effectiveTime);

  // Method to update sample data
  Future<Either<Failure, void>> updateSample(
      int requestId, Map<String, dynamic> sampleData);

  // Method to take all samples (set all collectorUserId)
  Future<Either<Failure, void>> takeAllSamples(
      int requestId, String collectorUserId);
}
