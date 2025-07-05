import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/patient_states.dart';
import '../../../../core/utils/app_logger.dart';
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

  @override
  Future<Either<Failure, SampleResponse>> getRequestSamples(
      int requestId) async {
    try {
      final result = await _remoteDataSource.getRequestSamples(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
          message: ErrorMessages.fetchPatientsError, code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error fetching samples: ${e.message}');
      return const Left(NetworkFailure(message: ErrorMessages.networkError));
    } catch (e, stackTrace) {
      AppLogger.error('Unknown error fetching samples: $e', stackTrace);
      return Left(UnknownFailure(
          message: 'Failed to parse sample data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Test>>> getRequestTests(int requestId) async {
    try {
      final result = await _remoteDataSource.getRequestTests(requestId);
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
  Future<Either<Failure, TestDetails>> getTestByCode(
      String testCode, String effectiveTime) async {
    try {
      final result =
          await _remoteDataSource.getTestByCode(testCode, effectiveTime);
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
  Future<Either<Failure, void>> updateSample(
      int requestId, Map<String, dynamic> sampleData) async {
    try {
      await _remoteDataSource.updateSample(requestId, sampleData);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Server error updating sample: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to update sample: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error updating sample: ${e.message}');
      if (e.message.toLowerCase().contains('timeout')) {
        return Left(
            NetworkFailure(message: ErrorMessages.sampleUpdateTimeoutError));
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unknown error updating sample: $e', stackTrace);
      return Left(
          UnknownFailure(message: 'Failed to update sample: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> takeAllSamples(
      int requestId, String collectorUserId) async {
    try {
      await _remoteDataSource.takeAllSamples(requestId, collectorUserId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('Server error taking all samples: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to take all samples: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error taking all samples: ${e.message}');
      if (e.message.toLowerCase().contains('timeout')) {
        return Left(NetworkFailure(
            message: ErrorMessages.sampleCollectionTimeoutError));
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unknown error taking all samples: $e', stackTrace);
      return Left(UnknownFailure(
          message: 'Failed to take all samples: ${e.toString()}'));
    }
  }
}
