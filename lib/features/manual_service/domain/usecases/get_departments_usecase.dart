import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/manual_service_repository.dart';
import '../../data/models/manual_service_models.dart';

@injectable
class GetDepartmentsUseCase {
  final ManualServiceRepository _repository;

  GetDepartmentsUseCase(this._repository);

  Future<Either<Failure, DepartmentResponse>> call(
      DepartmentQueryParams params) async {
    return await _repository.getDepartments(params);
  }
}
