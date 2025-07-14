import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class GenerateBarcodeUseCase {
  final ManualServiceRepository _repository;

  GenerateBarcodeUseCase(this._repository);

  Future<Either<Failure, BarcodePrintResponse>> call(
      BarcodePrintRequest request) async {
    return await _repository.generateBarcode(request);
  }
}
