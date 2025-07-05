import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class UpdateSampleUseCase {
  final PatientAdmissionsRepository _repository;

  UpdateSampleUseCase(this._repository);

  Future<Either<Failure, void>> call(
      int requestId, Map<String, dynamic> sampleData) async {
    return await _repository.updateSample(requestId, sampleData);
  }
}
