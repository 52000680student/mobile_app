import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_departments_usecase.dart';
import '../../domain/usecases/get_waiting_for_admission_usecase.dart';
import '../../domain/usecases/get_sample_taken_usecase.dart';
import 'patient_admissions_event.dart';
import 'patient_admissions_state.dart';

@injectable
class PatientAdmissionsBloc
    extends Bloc<PatientAdmissionsEvent, PatientAdmissionsState> {
  final GetDepartmentsUseCase _getDepartmentsUseCase;
  final GetWaitingForAdmissionUseCase _getWaitingForAdmissionUseCase;
  final GetSampleTakenUseCase _getSampleTakenUseCase;

  PatientAdmissionsBloc(
    this._getDepartmentsUseCase,
    this._getWaitingForAdmissionUseCase,
    this._getSampleTakenUseCase,
  ) : super(const PatientAdmissionsState()) {
    on<LoadDepartments>(_onLoadDepartments);
    on<LoadWaitingForAdmission>(_onLoadWaitingForAdmission);
    on<LoadSampleTaken>(_onLoadSampleTaken);
    on<LoadMoreWaitingForAdmission>(_onLoadMoreWaitingForAdmission);
    on<LoadMoreSampleTaken>(_onLoadMoreSampleTaken);
    on<ResetPatientAdmissions>(_onResetPatientAdmissions);
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<PatientAdmissionsState> emit,
  ) async {
    emit(state.copyWith(isLoadingDepartments: true, clearError: true));

    final result = await _getDepartmentsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingDepartments: false,
        errorMessage: failure.message,
      )),
      (departments) => emit(state.copyWith(
        isLoadingDepartments: false,
        departments: departments,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadWaitingForAdmission(
    LoadWaitingForAdmission event,
    Emitter<PatientAdmissionsState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingWaitingForAdmission: true,
      clearError: true,
    ));

    final result = await _getWaitingForAdmissionUseCase(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingWaitingForAdmission: false,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingWaitingForAdmission: false,
        waitingForAdmissionPatients:
            event.isRefresh ? response.data : response.data,
        hasReachedMaxWaitingForAdmission: response.last,
        currentWaitingForAdmissionPage: response.page,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadSampleTaken(
    LoadSampleTaken event,
    Emitter<PatientAdmissionsState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingSampleTaken: true,
      clearError: true,
    ));

    final result = await _getSampleTakenUseCase(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingSampleTaken: false,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingSampleTaken: false,
        sampleTakenPatients: event.isRefresh ? response.data : response.data,
        hasReachedMaxSampleTaken: response.last,
        currentSampleTakenPage: response.page,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadMoreWaitingForAdmission(
    LoadMoreWaitingForAdmission event,
    Emitter<PatientAdmissionsState> emit,
  ) async {
    if (state.hasReachedMaxWaitingForAdmission ||
        state.isLoadingMoreWaitingForAdmission) {
      return;
    }

    emit(state.copyWith(isLoadingMoreWaitingForAdmission: true));

    final result = await _getWaitingForAdmissionUseCase(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMoreWaitingForAdmission: false,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingMoreWaitingForAdmission: false,
        waitingForAdmissionPatients: [
          ...state.waitingForAdmissionPatients,
          ...response.data,
        ],
        hasReachedMaxWaitingForAdmission: response.last,
        currentWaitingForAdmissionPage: response.page,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadMoreSampleTaken(
    LoadMoreSampleTaken event,
    Emitter<PatientAdmissionsState> emit,
  ) async {
    if (state.hasReachedMaxSampleTaken || state.isLoadingMoreSampleTaken) {
      return;
    }

    emit(state.copyWith(isLoadingMoreSampleTaken: true));

    final result = await _getSampleTakenUseCase(event.params);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMoreSampleTaken: false,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        isLoadingMoreSampleTaken: false,
        sampleTakenPatients: [
          ...state.sampleTakenPatients,
          ...response.data,
        ],
        hasReachedMaxSampleTaken: response.last,
        currentSampleTakenPage: response.page,
        clearError: true,
      )),
    );
  }

  void _onResetPatientAdmissions(
    ResetPatientAdmissions event,
    Emitter<PatientAdmissionsState> emit,
  ) {
    emit(const PatientAdmissionsState());
  }
}
