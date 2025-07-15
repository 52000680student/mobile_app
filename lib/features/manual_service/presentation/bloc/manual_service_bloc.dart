import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/user_service.dart';
import '../../domain/usecases/search_patients_usecase.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_service_parameters_usecase.dart';
import '../../domain/usecases/get_test_services_usecase.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/save_manual_service_usecase.dart';
import '../../domain/usecases/get_request_samples_usecase.dart';
import '../../domain/usecases/save_barcode_usecase.dart';
import '../../domain/usecases/get_barcode_pdf_usecase.dart';
import '../../data/models/manual_service_models.dart';
import 'manual_service_event.dart';
import 'manual_service_state.dart';
import '../../../../core/utils/app_logger.dart';

@injectable
class ManualServiceBloc extends Bloc<ManualServiceEvent, ManualServiceState> {
  final SearchPatientsUseCase _searchPatientsUseCase;
  final GetDepartmentsUseCase _getDepartmentsUseCase;
  final GetServiceParametersUseCase _getServiceParametersUseCase;
  final GetTestServicesUseCase _getTestServicesUseCase;
  final GetDoctorsUseCase _getDoctorsUseCase;
  final SaveManualServiceUseCase _saveManualServiceUseCase;
  final GetRequestSamplesUseCase _getRequestSamplesUseCase;
  final SaveBarcodeUseCase _saveBarcodeUseCase;
  final GetBarcodePdfUseCase _getBarcodePdfUseCase;
  final UserService _userService;

  late final TextDebouncer _patientSearchDebouncer;

  ManualServiceBloc(
    this._searchPatientsUseCase,
    this._getDepartmentsUseCase,
    this._getServiceParametersUseCase,
    this._getTestServicesUseCase,
    this._getDoctorsUseCase,
    this._saveManualServiceUseCase,
    this._getRequestSamplesUseCase,
    this._saveBarcodeUseCase,
    this._getBarcodePdfUseCase,
    this._userService,
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
    on<LoadDoctorsEvent>(_onLoadDoctors);
    on<ToggleSampleCollectionEvent>(_onToggleSampleCollection);
    on<SelectDepartmentEvent>(_onSelectDepartment);
    on<SelectServiceParameterEvent>(_onSelectServiceParameter);
    on<AddTestServiceEvent>(_onAddTestService);
    on<RemoveTestServiceEvent>(_onRemoveTestService);
    on<ClearFormEvent>(_onClearForm);
    on<ResetPatientSearchEvent>(_onResetPatientSearch);
    on<LoadInitialPatientsEvent>(_onLoadInitialPatients);
    on<SaveManualServiceRequestEvent>(_onSaveManualServiceRequest);
    on<SaveBarcodeEvent>(_onSaveBarcode);
    on<SetCollectionTimeForAllSamplesEvent>(_onSetCollectionTimeForAllSamples);
    on<SetReceiveTimeForAllSamplesEvent>(_onSetReceiveTimeForAllSamples);
    on<PrintSuccessEvent>(_onPrintSuccess);
    on<ShowBarcodePdfPreviewEvent>(_onShowBarcodePdfPreview);
    on<ClearPdfPreviewEvent>(_onClearPdfPreview);

    // Load initial data
    add(const LoadDepartmentsEvent());
    add(const LoadServiceParametersEvent());
    add(const LoadDoctorsEvent()); // Load doctors
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

    AppLogger.info('Starting patient search with query: "${event.query}"');
    emit(state.copyWith(isSearchingPatients: true, patientSearchError: null));

    final params = PatientSearchQueryParams(query: event.query, size: 10);
    AppLogger.info('Created search params: ${params.toQueryParameters()}');

    final result = await _searchPatientsUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error('Patient search failed: ${failure.message}');
        emit(state.copyWith(
          isSearchingPatients: false,
          patientSearchError: failure.message,
        ));
      },
      (response) {
        AppLogger.info(
            'Patient search successful: found ${response.data.length} patients');
        AppLogger.info(
            'Patient search response: totalElements=${response.totalElements}, page=${response.page}');

        // Log first few patient names for debugging
        if (response.data.isNotEmpty) {
          final firstFewNames =
              response.data.take(3).map((p) => p.name).join(', ');
          AppLogger.info('First few patient names: $firstFewNames');
        }

        emit(state.copyWith(
          isSearchingPatients: false,
          patientSearchResults: response.data,
        ));

        AppLogger.info('State updated with ${response.data.length} patients');
      },
    );
  }

  Future<void> _onLoadInitialPatients(
    LoadInitialPatientsEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    AppLogger.info('Loading initial patients');
    emit(state.copyWith(isSearchingPatients: true, patientSearchError: null));

    // Load initial patients without search query (query: null means no 'q' parameter)
    final params = PatientSearchQueryParams(
      query: null, // No search query - loads all patients
      size: 15, // Load more initially for better UX
      page: 1,
    );
    AppLogger.info(
        'Created initial load params: ${params.toQueryParameters()}');

    final result = await _searchPatientsUseCase(params);

    result.fold(
      (failure) {
        AppLogger.error('Initial patient load failed: ${failure.message}');
        emit(state.copyWith(
          isSearchingPatients: false,
          patientSearchError: failure.message,
        ));
      },
      (response) {
        AppLogger.info(
            'Initial patient load successful: found ${response.data.length} patients');
        emit(state.copyWith(
          isSearchingPatients: false,
          patientSearchResults: response.data,
        ));
      },
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

  Future<void> _onLoadDoctors(
    LoadDoctorsEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    emit(state.copyWith(isLoadingDoctors: true, doctorsError: null));

    final result = await _getDoctorsUseCase(event.params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingDoctors: false,
        doctorsError: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingDoctors: false,
        doctors: response.data,
      )),
    );
  }

  void _onToggleSampleCollection(
    ToggleSampleCollectionEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.copyWith(areSamplesCollected: event.isCollected));
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

  Future<void> _onSaveManualServiceRequest(
    SaveManualServiceRequestEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    AppLogger.info('Starting manual service request save');
    emit(state.copyWith(isSavingRequest: true, saveError: null));

    final result = await _saveManualServiceUseCase(event.request);

    result.fold(
      (failure) {
        AppLogger.error(
            'Manual service request save failed: ${failure.message}');
        emit(state.copyWith(
          isSavingRequest: false,
          saveError: failure.message,
        ));
      },
      (response) {
        AppLogger.info(
            'Manual service request save successful: ID=${response.id}');
        emit(state.copyWith(
          isSavingRequest: false,
          saveResponse: response,
          currentRequestId:
              response.id, // Store request ID for barcode functionality
        ));
      },
    );
  }

  Future<void> _onSaveBarcode(
    SaveBarcodeEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    // Check if we have a request ID
    if (state.currentRequestId == null) {
      emit(state.copyWith(
        barcodeError: 'No request ID available. Please save the request first.',
      ));
      return;
    }

    AppLogger.info('Starting barcode save for sample: ${event.sample.type}');
    emit(state.copyWith(
      isSavingBarcode: true,
      barcodeError: null,
      barcodeSuccessMessage: null,
    ));

    final result = await _saveBarcodeUseCase(
      requestId: state.currentRequestId!,
      sample: event.sample,
      baseUrl: event.baseUrl,
      appointmentDate: event.appointmentDate,
    );

    result.fold(
      (failure) {
        AppLogger.error('Barcode save failed: ${failure.message}');
        emit(state.copyWith(
          isSavingBarcode: false,
          barcodeError: failure.message,
        ));
      },
      (savedPath) {
        AppLogger.info('Barcode save successful: $savedPath');
        emit(state.copyWith(
          isSavingBarcode: false,
          barcodeSuccessMessage: 'Barcode saved successfully to: $savedPath',
        ));
      },
    );
  }

  Future<void> _onSetCollectionTimeForAllSamples(
    SetCollectionTimeForAllSamplesEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    try {
      // Get current time and user ID
      final currentTime = DateTime.now();
      final currentUserId = await _userService.getCurrentUserIdWithFallback();
      final userIdInt = int.tryParse(currentUserId) ?? 1000004;

      AppLogger.info(
          'Setting collection time for all samples to: $currentTime with user ID: $userIdInt');

      final updatedSamples = state.sampleItems.map((sample) {
        return sample.copyWith(
          collectionTime: currentTime,
          collectionUserId: userIdInt,
        );
      }).toList();

      emit(state.copyWith(sampleItems: updatedSamples));
    } catch (e) {
      AppLogger.error('Error setting collection time for all samples: $e');
    }
  }

  Future<void> _onSetReceiveTimeForAllSamples(
    SetReceiveTimeForAllSamplesEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    try {
      // Get current time and user ID
      final currentTime = DateTime.now();
      final currentUserId = await _userService.getCurrentUserIdWithFallback();
      final userIdInt = int.tryParse(currentUserId) ?? 1000004;

      AppLogger.info(
          'Setting receive time for all samples to: $currentTime with user ID: $userIdInt');

      final updatedSamples = state.sampleItems.map((sample) {
        return sample.copyWith(
          receiveTime: currentTime,
          receiveUserId: userIdInt,
        );
      }).toList();

      emit(state.copyWith(sampleItems: updatedSamples));
    } catch (e) {
      AppLogger.error('Error setting receive time for all samples: $e');
    }
  }

  void _onPrintSuccess(
    PrintSuccessEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    // Handle successful print operation
    AppLogger.info('Print operation completed successfully');
    // You can add additional logic here if needed
    // For example, updating print statistics, clearing print queue, etc.
  }

  Future<void> _onShowBarcodePdfPreview(
    ShowBarcodePdfPreviewEvent event,
    Emitter<ManualServiceState> emit,
  ) async {
    // Check if we have a request ID
    if (state.currentRequestId == null) {
      emit(state.copyWith(
        pdfPreviewError:
            'No request ID available. Please save the request first.',
      ));
      return;
    }

    AppLogger.info('Starting PDF preview for sample: ${event.sample.type}');
    emit(state.copyWith(
      isLoadingPdfPreview: true,
      pdfPreviewError: null,
    ));

    final result = await _getBarcodePdfUseCase(
      requestId: state.currentRequestId!,
      sample: event.sample,
      baseUrl: event.baseUrl,
      appointmentDate: event.appointmentDate,
    );

    result.fold(
      (failure) {
        AppLogger.error('PDF preview failed: ${failure.message}');
        emit(state.copyWith(
          isLoadingPdfPreview: false,
          pdfPreviewError: failure.message,
        ));
      },
      (pdfBytes) {
        AppLogger.info('PDF preview successful, got ${pdfBytes.length} bytes');
        emit(state.copyWith(
          isLoadingPdfPreview: false,
          pdfPreviewBytes: pdfBytes,
          pdfPreviewSample: event.sample,
        ));
      },
    );
  }

  void _onClearPdfPreview(
    ClearPdfPreviewEvent event,
    Emitter<ManualServiceState> emit,
  ) {
    emit(state.copyWith(
      pdfPreviewBytes: null,
      pdfPreviewSample: null,
      pdfPreviewError: null,
    ));
  }

  @override
  Future<void> close() {
    _patientSearchDebouncer.dispose();
    return super.close();
  }
}
