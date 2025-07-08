import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class GetServiceParametersUseCase {
  final ManualServiceRepository _repository;

  GetServiceParametersUseCase(this._repository);

  Future<Either<Failure, List<ServiceParameter>>> call() async {
    return await _repository.getServiceParameters();
  }
}
