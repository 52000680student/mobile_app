import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class GetTestByCodeUseCase {
  final PatientAdmissionsRepository _repository;

  GetTestByCodeUseCase(this._repository);

  Future<Either<Failure, TestDetails>> call(
      String testCode, String effectiveTime) async {
    return await _repository.getTestByCode(testCode, effectiveTime);
  }
}
