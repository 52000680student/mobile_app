import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';

abstract class PatientAdmissionsRepository {
  Future<Either<Failure, List<DepartmentParameter>>> getDepartments();
  Future<Either<Failure, PatientVisitResponse>> getWaitingForAdmission(
      PatientVisitQueryParams params);
  Future<Either<Failure, PatientVisitResponse>> getSampleTaken(
      PatientVisitQueryParams params);
}
