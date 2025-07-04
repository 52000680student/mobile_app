import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/patient_states.dart';
import '../../domain/repositories/patient_admissions_repository.dart';
import '../datasources/patient_admissions_remote_datasource.dart';
import '../models/patient_models.dart';

@LazySingleton(as: PatientAdmissionsRepository)
class PatientAdmissionsRepositoryImpl implements PatientAdmissionsRepository {
  final PatientAdmissionsRemoteDataSource _remoteDataSource;

  PatientAdmissionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<DepartmentParameter>>> getDepartments() async {
    try {
      final result = await _remoteDataSource.getDepartments();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
          message: ErrorMessages.fetchDepartmentsError, code: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure(message: ErrorMessages.networkError));
    } catch (e) {
      return const Left(UnknownFailure(message: ErrorMessages.unknownError));
    }
  }

  @override
  Future<Either<Failure, PatientVisitResponse>> getWaitingForAdmission(
      PatientVisitQueryParams params) async {
    try {
      final result = await _remoteDataSource.getWaitingForAdmission(params);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
          message: ErrorMessages.fetchPatientsError, code: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure(message: ErrorMessages.networkError));
    } catch (e) {
      return const Left(UnknownFailure(message: ErrorMessages.unknownError));
    }
  }

  @override
  Future<Either<Failure, PatientVisitResponse>> getSampleTaken(
      PatientVisitQueryParams params) async {
    try {
      final result = await _remoteDataSource.getSampleTaken(params);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
          message: ErrorMessages.fetchPatientsError, code: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure(message: ErrorMessages.networkError));
    } catch (e) {
      return const Left(UnknownFailure(message: ErrorMessages.unknownError));
    }
  }
}
