import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/patient_models.dart';
import '../repositories/patient_admissions_repository.dart';

@injectable
class GetDepartmentsUseCase {
  final PatientAdmissionsRepository _repository;

  GetDepartmentsUseCase(this._repository);

  Future<Either<Failure, List<DepartmentParameter>>> call() async {
    return await _repository.getDepartments();
  }
}
