import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/manual_service_models.dart';

abstract class ManualServiceRepository {
  /// Search patients by query
  Future<Either<Failure, PatientSearchResponse>> searchPatients(
      PatientSearchQueryParams params);

  /// Get departments list
  Future<Either<Failure, DepartmentResponse>> getDepartments(
      DepartmentQueryParams params);

  /// Get service parameters (L125 codes)
  Future<Either<Failure, List<ServiceParameter>>> getServiceParameters();

  /// Get test services
  Future<Either<Failure, TestServiceResponse>> getTestServices(
      TestServiceQueryParams params);
}
