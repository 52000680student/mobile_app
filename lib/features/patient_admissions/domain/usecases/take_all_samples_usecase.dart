import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class TakeAllSamplesUseCase {
  final PatientAdmissionsRepository _repository;

  TakeAllSamplesUseCase(this._repository);

  Future<Either<Failure, void>> call(
      int requestId, String collectorUserId) async {
    return await _repository.takeAllSamples(requestId, collectorUserId);
  }
}
