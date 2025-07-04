import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class GetRequestTestsUseCase {
  final PatientAdmissionsRepository _repository;

  GetRequestTestsUseCase(this._repository);

  Future<Either<Failure, List<Test>>> call(int requestId) async {
    return await _repository.getRequestTests(requestId);
  }
}
