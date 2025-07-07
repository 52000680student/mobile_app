import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/debouncer.dart';
import '../../domain/usecases/search_patients_usecase.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_service_parameters_usecase.dart';
import '../../domain/usecases/get_test_services_usecase.dart';
import '../../data/models/manual_service_models.dart';
import 'manual_service_event.dart';
import 'manual_service_state.dart';

@injectable
class ManualServiceBloc extends Bloc<ManualServiceEvent, ManualServiceState> {
  final SearchPatientsUseCase _searchPatientsUseCase;
  final GetDepartmentsUseCase _getDepartmentsUseCase;
  final GetServiceParametersUseCase _getServiceParametersUseCase;
  final GetTestServicesUseCase _getTestServicesUseCase;

  late final TextDebouncer _patientSearchDebouncer;

  ManualServiceBloc(
    this._searchPatientsUseCase,
    this._getDepartmentsUseCase,
    this._getServiceParametersUseCase,
    this._getTestServicesUseCase,
  ) : super(const ManualServiceState()) {
    _patientSearchDebouncer = TextDebouncer(
      onChanged: (query) => add(SearchPatientsEvent(query)),
      delay: const Duration(milliseconds: 300),
    );

    on<SearchPatientsEvent>(_onSearchPatients);
    on<SelectPatientEvent>(_onSelectPatient);
    on<LoadDepartmentsEvent>(_onLoadDepartments);
    on<LoadServiceParametersEvent>(_onLoadServiceParameters);
    on<LoadTestServicesEvent>(_onLoadTestServices);
    on<SelectDepartmentEvent>(_onSelectDepartment);
    on<SelectServiceParameterEvent>(_onSelectServiceParameter);
    on<AddTestServiceEvent>(_onAddTestService);
    on<RemoveTestServiceEvent>(_onRemoveTestService);
    on<ClearFormEvent>(_onClearForm);
    on<ResetPatientSearchEvent>(_onResetPatientSearch);
    on<LoadInitialPatientsEvent>(_onLoadInitialPatients);

    // Load initial data
    add(const LoadDepartmentsEvent());
    add(const LoadServiceParametersEvent());
    add(const LoadInitialPatientsEvent()); // Load initial patients
  }

  void searchPatients(String query) {
    _patientSearchDebouncer.process(query);
  }

  Future<void> _onSearchPatients(
    SearchPatientsEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    if (event.query.isEmpty) {
      // When search is cleared, reload initial patients instead of clearing
      add(const LoadInitialPatientsEvent());
      return;
    }

    emit(state.copyWith(isSearchingPatients: true, patientSearchError: null));

    final params = PatientSearchQueryParams(query: event.query, size: 10);
    final result = await _searchPatientsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isSearchingPatients: false,
        patientSearchError: failure.message,
      )),
      (response) => emit(state.copyWith(
        isSearchingPatients: false,
        patientSearchResults: response.data,
      )),
    );
  }

  Future<void> _onLoadInitialPatients(
    LoadInitialPatientsEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    emit(state.copyWith(isSearchingPatients: true, patientSearchError: null));

    // Load initial patients without search query (query: null means no 'q' parameter)
    final params = PatientSearchQueryParams(
      query: null, // No search query - loads all patients
      size: 15, // Load more initially for better UX
      page: 1,
    );
    final result = await _searchPatientsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isSearchingPatients: false,
        patientSearchError: failure.message,
      )),
      (response) => emit(state.copyWith(
        isSearchingPatients: false,
        patientSearchResults: response.data,
      )),
    );
  }

  void _onSelectPatient(
    SelectPatientEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.copyWith(
      selectedPatient: event.patient,
      patientSearchResults: [], // Clear search results after selection
    ));
  }

  Future<void> _onLoadDepartments(
    LoadDepartmentsEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    emit(state.copyWith(isLoadingDepartments: true, departmentsError: null));

    final params = DepartmentQueryParams();
    final result = await _getDepartmentsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingDepartments: false,
        departmentsError: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingDepartments: false,
        departments: response.data.where((dept) => dept.status).toList(),
      )),
    );
  }

  Future<void> _onLoadServiceParameters(
    LoadServiceParametersEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    emit(state.copyWith(
        isLoadingServiceParameters: true, serviceParametersError: null));

    final result = await _getServiceParametersUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingServiceParameters: false,
        serviceParametersError: failure.message,
      )),
      (serviceParameters) => emit(state.copyWith(
        isLoadingServiceParameters: false,
        serviceParameters: serviceParameters,
      )),
    );
  }

  Future<void> _onLoadTestServices(
    LoadTestServicesEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    emit(state.copyWith(isLoadingTestServices: true, testServicesError: null));

    final params = TestServiceQueryParams();
    final result = await _getTestServicesUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingTestServices: false,
        testServicesError: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingTestServices: false,
        availableTestServices:
            response.data.where((test) => test.inUse).toList(),
      )),
    );
  }

  void _onSelectDepartment(
    SelectDepartmentEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.copyWith(selectedDepartment: event.department));
  }

  void _onSelectServiceParameter(
    SelectServiceParameterEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.copyWith(selectedServiceParameter: event.serviceParameter));
  }

  void _onAddTestService(
    AddTestServiceEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    // Check if service is already added
    final isAlreadyAdded = state.selectedTestServices
        .any((service) => service.id == event.testService.id);

    if (!isAlreadyAdded) {
      final updatedServices = [
        ...state.selectedTestServices,
        event.testService
      ];
      final updatedSamples = [
        ...state.sampleItems,
        SampleItem.fromTestService(event.testService)
      ];

      emit(state.copyWith(
        selectedTestServices: updatedServices,
        sampleItems: updatedSamples,
      ));
    }
  }

  void _onRemoveTestService(
    RemoveTestServiceEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    final updatedServices = state.selectedTestServices
        .where((service) => service.id != event.testService.id)
        .toList();

    final updatedSamples = state.sampleItems
        .where((sample) => sample.name != event.testService.sampleTypeName)
        .toList();

    emit(state.copyWith(
      selectedTestServices: updatedServices,
      sampleItems: updatedSamples,
    ));
  }

  void _onClearForm(
    ClearFormEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.clearForm());
  }

  void _onResetPatientSearch(
    ResetPatientSearchEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    // Instead of clearing, reload initial patients
    add(const LoadInitialPatientsEvent());
  }

  /// Get filtered departments by search query
  List<Department> getFilteredDepartments(String query) {
    if (query.isEmpty) return state.departments;

    return state.departments
        .where((dept) => dept.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get filtered test services by search query
  List<TestService> getFilteredTestServices(String query) {
    if (query.isEmpty) return state.availableTestServices;

    return state.availableTestServices
        .where((test) =>
            test.testName.toLowerCase().contains(query.toLowerCase()) ||
            test.testCode.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> close() {
    _patientSearchDebouncer.dispose();
    return super.close();
  }
}
