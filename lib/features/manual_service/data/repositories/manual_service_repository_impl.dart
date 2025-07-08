import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:typed_data';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/manual_service_repository.dart';
import '../datasources/manual_service_remote_datasource.dart';
import '../models/manual_service_models.dart';
import '../../../patient_admissions/data/models/patient_models.dart'; // Added for SampleResponse

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

  @override
  Future<Either<Failure, DoctorResponse>> getDoctors(
      DoctorQueryParams params) async {
    try {
      final result = await _remoteDataSource.getDoctors(params);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in getDoctors: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to fetch doctors: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getDoctors: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in getDoctors: $e');
      return Left(
          UnknownFailure(message: 'Failed to fetch doctors: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ManualServiceRequestResponse>>
      saveManualServiceRequest(ManualServiceRequest request) async {
    try {
      final result = await _remoteDataSource.saveManualServiceRequest(request);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in saveManualServiceRequest: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to save manual service request: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error(
          'Network error in saveManualServiceRequest: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in saveManualServiceRequest: $e');
      return Left(UnknownFailure(
          message: 'Failed to save manual service request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SampleResponse>> getRequestSamples(
      int requestId) async {
    try {
      final result = await _remoteDataSource.getRequestSamples(requestId);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in getRequestSamples: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to get request samples: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getRequestSamples: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in getRequestSamples: $e');
      return Left(UnknownFailure(
          message: 'Failed to get request samples: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarcodePrintResponse>> generateBarcode(
      BarcodePrintRequest request) async {
    try {
      final result = await _remoteDataSource.generateBarcode(request);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in generateBarcode: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to generate barcode: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in generateBarcode: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in generateBarcode: $e');
      return Left(UnknownFailure(
          message: 'Failed to generate barcode: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadBarcodeImage(
      String reportUrl) async {
    try {
      final result = await _remoteDataSource.downloadBarcodeImage(reportUrl);
      return Right(result);
    } on ServerException catch (e) {
      AppLogger.error('Server error in downloadBarcodeImage: ${e.message}');
      return Left(ServerFailure(
          message: 'Failed to download barcode image: ${e.message}',
          code: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in downloadBarcodeImage: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Unknown error in downloadBarcodeImage: $e');
      return Left(UnknownFailure(
          message: 'Failed to download barcode image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> saveBarcodeToGallery(
      List<int> imageBytes, String fileName) async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (permission != PermissionStatus.granted) {
        return const Left(UnknownFailure(message: 'Storage permission denied'));
      }

      // Convert bytes to Uint8List
      final uint8List = Uint8List.fromList(imageBytes);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        uint8List,
        name: fileName,
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        final savedPath = result['filePath'] ?? 'Photo gallery';
        AppLogger.info('Successfully saved barcode image to: $savedPath');
        return Right(savedPath);
      } else {
        AppLogger.error(
            'Failed to save barcode image: ${result['errorMessage']}');
        return Left(UnknownFailure(
            message:
                'Failed to save barcode image: ${result['errorMessage']}'));
      }
    } catch (e) {
      AppLogger.error('Unknown error in saveBarcodeToGallery: $e');
      return Left(UnknownFailure(
          message: 'Failed to save barcode to gallery: ${e.toString()}'));
    }
  }
}
