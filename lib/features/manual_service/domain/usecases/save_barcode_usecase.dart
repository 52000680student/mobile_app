import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';
import '../../../patient_admissions/data/models/patient_models.dart';

@injectable
class SaveBarcodeUseCase {
  final ManualServiceRepository _repository;

  SaveBarcodeUseCase(this._repository);

  /// Complete barcode saving process for a specific sample
  Future<Either<Failure, String>> call({
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
              // Step 5: Download barcode image
              final fullReportUrl = baseUrl + barcodeResponse.reportUrl;
              final downloadResult =
                  await _repository.downloadBarcodeImage(fullReportUrl);

              return await downloadResult.fold(
                (failure) async => Left(failure),
                (imageBytes) async {
                  // Step 6: Save to gallery
                  final fileName =
                      'barcode_${matchingSample.sid}_${DateTime.now().millisecondsSinceEpoch}.png';
                  final saveResult = await _repository.saveBarcodeToGallery(
                      imageBytes, fileName);

                  return saveResult.fold(
                    (failure) => Left(failure),
                    (savedPath) {
                      AppLogger.info(
                          'Successfully saved barcode for sample ${matchingSample.sid} to: $savedPath');
                      return Right(savedPath);
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error in SaveBarcodeUseCase: $e');
      return Left(
          UnknownFailure(message: 'Failed to save barcode: ${e.toString()}'));
    }
  }
}
