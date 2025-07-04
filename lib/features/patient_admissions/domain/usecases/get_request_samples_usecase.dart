import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class GetRequestSamplesUseCase {
  final PatientAdmissionsRepository _repository;

  GetRequestSamplesUseCase(this._repository);

  Future<Either<Failure, SampleResponse>> call(int requestId) async {
    return await _repository.getRequestSamples(requestId);
  }
}
