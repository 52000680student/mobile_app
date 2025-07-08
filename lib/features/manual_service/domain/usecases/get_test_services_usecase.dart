import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class GetTestServicesUseCase {
  final ManualServiceRepository _repository;

  GetTestServicesUseCase(this._repository);

  Future<Either<Failure, TestServiceResponse>> call(
      TestServiceQueryParams params) async {
    return await _repository.getTestServices(params);
  }
}
