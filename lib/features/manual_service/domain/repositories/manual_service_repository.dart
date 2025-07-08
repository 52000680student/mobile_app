import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/manual_service_models.dart';
import '../../../patient_admissions/data/models/patient_models.dart'; // Added for SampleResponse

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

  /// Get doctors list
  Future<Either<Failure, DoctorResponse>> getDoctors(DoctorQueryParams params);

  /// Save manual service request
  Future<Either<Failure, ManualServiceRequestResponse>>
      saveManualServiceRequest(ManualServiceRequest request);

  /// Get request samples for barcode generation
  Future<Either<Failure, SampleResponse>> getRequestSamples(int requestId);

  /// Generate barcode from print API
  Future<Either<Failure, BarcodePrintResponse>> generateBarcode(
      BarcodePrintRequest request);

  /// Download barcode PDF as bytes from report URL
  Future<Either<Failure, List<int>>> downloadBarcodePdf(String reportUrl);

  /// Save barcode PDF to device storage
  Future<Either<Failure, String>> saveBarcodePdf(
      List<int> pdfBytes, String fileName);
}
