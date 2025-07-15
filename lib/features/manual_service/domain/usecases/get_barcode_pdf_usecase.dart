import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class GetBarcodePdfUseCase {
  final ManualServiceRepository _repository;

  GetBarcodePdfUseCase(this._repository);

  /// Get barcode PDF bytes for preview
  Future<Either<Failure, Uint8List>> call({
    required int requestId,
    required SampleItem sample,
    required String baseUrl,
    DateTime? appointmentDate,
  }) async {
    try {
      // Step 1: Get request samples
      final samplesResult = await _repository.getRequestSamples(requestId);

      return await samplesResult.fold(
        (failure) async => Left(failure),
        (sampleResponse) async {
          // Step 2: Find the matching sample by type
          final matchingSample = sampleResponse.samples.firstWhere(
            (apiSample) => apiSample.sampleType == sample.type,
            orElse: () => throw Exception(
                'Sample type ${sample.type} not found in request $requestId'),
          );

          // Step 3: Create barcode data using appointmentDate if provided, otherwise use sample's requestDate
          final barcodeData = BarcodeData.fromSample(
            sample: matchingSample,
            requestDate: appointmentDate?.toIso8601String() ??
                matchingSample.requestDate,
          );

          final barcodeRequest = barcodeData.toBarcodePrintRequest();

          // Step 4: Generate barcode
          final barcodeResult =
              await _repository.generateBarcode(barcodeRequest);

          return await barcodeResult.fold(
            (failure) async => Left(failure),
            (barcodeResponse) async {
              // Step 5: Download barcode PDF bytes
              final fullReportUrl = baseUrl + barcodeResponse.reportUrl;
              final downloadResult =
                  await _repository.downloadBarcodePdf(fullReportUrl);

              return await downloadResult.fold(
                (failure) async => Left(failure),
                (pdfBytes) async {
                  AppLogger.info(
                      'Successfully retrieved barcode PDF bytes for sample ${matchingSample.sid}');
                  return Right(Uint8List.fromList(pdfBytes));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error in GetBarcodePdfUseCase: $e');
      return Left(UnknownFailure(
          message: 'Failed to get barcode PDF: ${e.toString()}'));
    }
  }
}
