import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/manual_service_repository.dart';
import '../datasources/manual_service_remote_datasource.dart';
import '../models/manual_service_models.dart';

@LazySingleton(as: ManualServiceRepository)
class ManualServiceRepositoryImpl implements ManualServiceRepository {
  final ManualServiceRemoteDataSource _remoteDataSource;

  ManualServiceRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PatientSearchResponse>> searchPatients(
      PatientSearchQueryParams params) async {
    try {
      final result = await _remoteDataSource.searchPatients(params);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in searchPatients: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to search patients: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in searchPatients: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in searchPatients: $e');
      return Left(UnknownFailure(
          message: 'Failed to search patients: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DepartmentResponse>> getDepartments(
      DepartmentQueryParams params) async {
    try {
      final result = await _remoteDataSource.getDepartments(params);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in getDepartments: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to fetch departments: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getDepartments: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in getDepartments: $e');
      return Left(UnknownFailure(
          message: 'Failed to fetch departments: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceParameter>>> getServiceParameters() async {
    try {
      final result = await _remoteDataSource.getServiceParameters();
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in getServiceParameters: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to fetch service parameters: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getServiceParameters: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in getServiceParameters: $e');
      return Left(UnknownFailure(
          message: 'Failed to fetch service parameters: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TestServiceResponse>> getTestServices(
      TestServiceQueryParams params) async {
    try {
      final result = await _remoteDataSource.getTestServices(params);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in getTestServices: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to fetch test services: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getTestServices: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in getTestServices: $e');
      return Left(UnknownFailure(
          message: 'Failed to fetch test services: ${e.toString()}'));
    }
  }
}
