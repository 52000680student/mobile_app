import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../../patient_admissions/data/models/patient_models.dart';

@injectable
class GetRequestSamplesUseCase {
  final ManualServiceRepository _repository;

  GetRequestSamplesUseCase(this._repository);

  Future<Either<Failure, SampleResponse>> call(int requestId) async {
    return await _repository.getRequestSamples(requestId);
  }
}
