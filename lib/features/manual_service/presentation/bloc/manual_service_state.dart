import 'package:equatable/equatable.dart';
import '../../data/models/manual_service_models.dart';

class ManualServiceState extends Equatable {
  // Patient search
  final bool isSearchingPatients;
  final List<PatientSearchResult> patientSearchResults;
  final PatientSearchResult? selectedPatient;
  final String? patientSearchError;

  // Departments
  final bool isLoadingDepartments;
  final List<Department> departments;
  final Department? selectedDepartment;
  final String? departmentsError;

  // Service parameters
  final bool isLoadingServiceParameters;
  final List<ServiceParameter> serviceParameters;
  final ServiceParameter? selectedServiceParameter;
  final String? serviceParametersError;

  // Test services
  final bool isLoadingTestServices;
  final List<TestService> availableTestServices;
  final List<TestService> selectedTestServices;
  final List<SampleItem> sampleItems;
  final String? testServicesError;

  // Doctors
  final bool isLoadingDoctors;
  final List<Doctor> doctors;
  final Doctor? selectedDoctor;
  final String? doctorsError;

  // Sample collection state
  final bool areSamplesCollected;

  // Form state
  final bool isFormValid;
  final String? formError;

  // Save request state
  final bool isSavingRequest;
  final ManualServiceRequestResponse? saveResponse;
  final String? saveError;

  const ManualServiceState({
    this.isSearchingPatients = false,
    this.patientSearchResults = const [],
    this.selectedPatient,
    this.patientSearchError,
    this.isLoadingDepartments = false,
    this.departments = const [],
    this.selectedDepartment,
    this.departmentsError,
    this.isLoadingServiceParameters = false,
    this.serviceParameters = const [],
    this.selectedServiceParameter,
    this.serviceParametersError,
    this.isLoadingTestServices = false,
    this.availableTestServices = const [],
    this.selectedTestServices = const [],
    this.sampleItems = const [],
    this.testServicesError,
    this.isLoadingDoctors = false,
    this.doctors = const [],
    this.selectedDoctor,
    this.doctorsError,
    this.areSamplesCollected = false,
    this.isFormValid = false,
    this.formError,
    this.isSavingRequest = false,
    this.saveResponse,
    this.saveError,
  });

  ManualServiceState copyWith({
    bool? isSearchingPatients,
    List<PatientSearchResult>? patientSearchResults,
    PatientSearchResult? selectedPatient,
    String? patientSearchError,
    bool? isLoadingDepartments,
    List<Department>? departments,
    Department? selectedDepartment,
    String? departmentsError,
    bool? isLoadingServiceParameters,
    List<ServiceParameter>? serviceParameters,
    ServiceParameter? selectedServiceParameter,
    String? serviceParametersError,
    bool? isLoadingTestServices,
    List<TestService>? availableTestServices,
    List<TestService>? selectedTestServices,
    List<SampleItem>? sampleItems,
    String? testServicesError,
    bool? isLoadingDoctors,
    List<Doctor>? doctors,
    Doctor? selectedDoctor,
    String? doctorsError,
    bool? areSamplesCollected,
    bool? isFormValid,
    String? formError,
    bool? isSavingRequest,
    ManualServiceRequestResponse? saveResponse,
    String? saveError,
  }) {
    return ManualServiceState(
      isSearchingPatients: isSearchingPatients ?? this.isSearchingPatients,
      patientSearchResults: patientSearchResults ?? this.patientSearchResults,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      patientSearchError: patientSearchError ?? this.patientSearchError,
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      departments: departments ?? this.departments,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      departmentsError: departmentsError ?? this.departmentsError,
      isLoadingServiceParameters:
          isLoadingServiceParameters ?? this.isLoadingServiceParameters,
      serviceParameters: serviceParameters ?? this.serviceParameters,
      selectedServiceParameter:
          selectedServiceParameter ?? this.selectedServiceParameter,
      serviceParametersError:
          serviceParametersError ?? this.serviceParametersError,
      isLoadingTestServices:
          isLoadingTestServices ?? this.isLoadingTestServices,
      availableTestServices:
          availableTestServices ?? this.availableTestServices,
      selectedTestServices: selectedTestServices ?? this.selectedTestServices,
      sampleItems: sampleItems ?? this.sampleItems,
      testServicesError: testServicesError ?? this.testServicesError,
      isLoadingDoctors: isLoadingDoctors ?? this.isLoadingDoctors,
      doctors: doctors ?? this.doctors,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      doctorsError: doctorsError ?? this.doctorsError,
      areSamplesCollected: areSamplesCollected ?? this.areSamplesCollected,
      isFormValid: isFormValid ?? this.isFormValid,
      formError: formError ?? this.formError,
      isSavingRequest: isSavingRequest ?? this.isSavingRequest,
      saveResponse: saveResponse ?? this.saveResponse,
      saveError: saveError ?? this.saveError,
    );
  }

  ManualServiceState clearPatientSearch() {
    return copyWith(
      patientSearchResults: [],
      patientSearchError: null,
    );
  }

  ManualServiceState clearSelectedPatient() {
    return copyWith(
      selectedPatient: null,
    );
  }

  ManualServiceState clearForm() {
    return copyWith(
      selectedPatient: null,
      selectedDepartment: null,
      selectedServiceParameter: null,
      selectedTestServices: [],
      sampleItems: [],
      patientSearchResults: [],
      selectedDoctor: null,
      areSamplesCollected: false,
      isFormValid: false,
      formError: null,
    );
  }

  ManualServiceState clearErrors() {
    return copyWith(
      patientSearchError: null,
      departmentsError: null,
      serviceParametersError: null,
      testServicesError: null,
      doctorsError: null,
      formError: null,
    );
  }

  bool get hasSelectedPatient => selectedPatient != null;
  bool get hasSelectedDepartment => selectedDepartment != null;
  bool get hasSelectedServiceParameter => selectedServiceParameter != null;
  bool get hasSelectedTestServices => selectedTestServices.isNotEmpty;

  bool get isLoading =>
      isSearchingPatients ||
      isLoadingDepartments ||
      isLoadingServiceParameters ||
      isLoadingTestServices ||
      isLoadingDoctors;

  bool get hasError =>
      patientSearchError != null ||
      departmentsError != null ||
      serviceParametersError != null ||
      testServicesError != null ||
      doctorsError != null ||
      formError != null;

  @override
  List<Object?> get props => [
        isSearchingPatients,
        patientSearchResults,
        selectedPatient,
        patientSearchError,
        isLoadingDepartments,
        departments,
        selectedDepartment,
        departmentsError,
        isLoadingServiceParameters,
        serviceParameters,
        selectedServiceParameter,
        serviceParametersError,
        isLoadingTestServices,
        availableTestServices,
        selectedTestServices,
        sampleItems,
        testServicesError,
        isLoadingDoctors,
        doctors,
        selectedDoctor,
        doctorsError,
        areSamplesCollected,
        isFormValid,
        formError,
        isSavingRequest,
        saveResponse,
        saveError,
      ];
}
