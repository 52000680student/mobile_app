import 'package:equatable/equatable.dart';
import '../../data/models/manual_service_models.dart';

abstract class ManualServiceEvent extends Equatable {
  const ManualServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search patients
class SearchPatientsEvent extends ManualServiceEvent {
  final String query;

  const SearchPatientsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to select a patient
class SelectPatientEvent extends ManualServiceEvent {
  final PatientSearchResult patient;

  const SelectPatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Event to load departments
class LoadDepartmentsEvent extends ManualServiceEvent {
  const LoadDepartmentsEvent();
}

/// Event to load service parameters
class LoadServiceParametersEvent extends ManualServiceEvent {
  const LoadServiceParametersEvent();
}

/// Event to load test services
class LoadTestServicesEvent extends ManualServiceEvent {
  const LoadTestServicesEvent();
}

/// Event to select a department
class SelectDepartmentEvent extends ManualServiceEvent {
  final Department department;

  const SelectDepartmentEvent(this.department);

  @override
  List<Object?> get props => [department];
}

/// Event to select a service parameter
class SelectServiceParameterEvent extends ManualServiceEvent {
  final ServiceParameter serviceParameter;

  const SelectServiceParameterEvent(this.serviceParameter);

  @override
  List<Object?> get props => [serviceParameter];
}

/// Event to add a test service to services
class AddTestServiceEvent extends ManualServiceEvent {
  final TestService testService;

  const AddTestServiceEvent(this.testService);

  @override
  List<Object?> get props => [testService];
}

/// Event to remove a test service from services
class RemoveTestServiceEvent extends ManualServiceEvent {
  final TestService testService;

  const RemoveTestServiceEvent(this.testService);

  @override
  List<Object?> get props => [testService];
}

/// Event to clear all form data
class ClearFormEvent extends ManualServiceEvent {
  const ClearFormEvent();
}

/// Event to reset patient search
class ResetPatientSearchEvent extends ManualServiceEvent {
  const ResetPatientSearchEvent();
}

/// Event to load initial patients (without search query)
class LoadInitialPatientsEvent extends ManualServiceEvent {
  const LoadInitialPatientsEvent();
}

/// Event to save manual service request
class SaveManualServiceRequestEvent extends ManualServiceEvent {
  final ManualServiceRequest request;

  const SaveManualServiceRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to load doctors list
class LoadDoctorsEvent extends ManualServiceEvent {
  final DoctorQueryParams params;

  const LoadDoctorsEvent({
    this.params = const DoctorQueryParams(),
  });

  @override
  List<Object?> get props => [params];
}

/// Event to toggle sample collection state
class ToggleSampleCollectionEvent extends ManualServiceEvent {
  final bool isCollected;

  const ToggleSampleCollectionEvent(this.isCollected);

  @override
  List<Object?> get props => [isCollected];
}

/// Event to save barcode for a specific sample
class SaveBarcodeEvent extends ManualServiceEvent {
  final SampleItem sample;
  final String baseUrl;

  const SaveBarcodeEvent({
    required this.sample,
    required this.baseUrl,
  });

  @override
  List<Object?> get props => [sample, baseUrl];
}
