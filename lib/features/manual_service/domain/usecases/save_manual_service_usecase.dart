import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class SaveManualServiceUseCase {
  final ManualServiceRepository _repository;

  SaveManualServiceUseCase(this._repository);

  Future<Either<Failure, ManualServiceRequestResponse>> call(
      ManualServiceRequest request) async {
    return await _repository.saveManualServiceRequest(request);
  }
}
