import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class SearchPatientsUseCase {
  final ManualServiceRepository _repository;

  SearchPatientsUseCase(this._repository);

  Future<Either<Failure, PatientSearchResponse>> call(
      PatientSearchQueryParams params) async {
    return await _repository.searchPatients(params);
  }
}
