import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/manual_service_models.dart';
import '../repositories/manual_service_repository.dart';

@injectable
class GetDoctorsUseCase {
  final ManualServiceRepository _repository;

  GetDoctorsUseCase(this._repository);

  Future<Either<Failure, DoctorResponse>> call(DoctorQueryParams params) async {
    return await _repository.getDoctors(params);
  }
}
