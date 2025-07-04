import 'package:equatable/equatable.dart';
import '../../data/models/patient_models.dart';

abstract class PatientAdmissionsEvent extends Equatable {
  const PatientAdmissionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDepartments extends PatientAdmissionsEvent {
  const LoadDepartments();
}

class LoadWaitingForAdmission extends PatientAdmissionsEvent {
  final PatientVisitQueryParams params;
  final bool isRefresh;

  const LoadWaitingForAdmission({
    required this.params,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [params, isRefresh];
}

class LoadSampleTaken extends PatientAdmissionsEvent {
  final PatientVisitQueryParams params;
  final bool isRefresh;

  const LoadSampleTaken({
    required this.params,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [params, isRefresh];
}

class LoadMoreWaitingForAdmission extends PatientAdmissionsEvent {
  final PatientVisitQueryParams params;

  const LoadMoreWaitingForAdmission({required this.params});

  @override
  List<Object?> get props => [params];
}

class LoadMoreSampleTaken extends PatientAdmissionsEvent {
  final PatientVisitQueryParams params;

  const LoadMoreSampleTaken({required this.params});

  @override
  List<Object?> get props => [params];
}

class ResetPatientAdmissions extends PatientAdmissionsEvent {
  const ResetPatientAdmissions();
}
