import 'package:equatable/equatable.dart';
import '../../data/models/patient_models.dart';

class PatientAdmissionsState extends Equatable {
  final bool isLoadingDepartments;
  final bool isLoadingWaitingForAdmission;
  final bool isLoadingSampleTaken;
  final bool isLoadingMoreWaitingForAdmission;
  final bool isLoadingMoreSampleTaken;

  final List<DepartmentParameter> departments;
  final List<PatientVisit> waitingForAdmissionPatients;
  final List<PatientVisit> sampleTakenPatients;

  final bool hasReachedMaxWaitingForAdmission;
  final bool hasReachedMaxSampleTaken;
  final int currentWaitingForAdmissionPage;
  final int currentSampleTakenPage;

  final String? errorMessage;

  const PatientAdmissionsState({
    this.isLoadingDepartments = false,
    this.isLoadingWaitingForAdmission = false,
    this.isLoadingSampleTaken = false,
    this.isLoadingMoreWaitingForAdmission = false,
    this.isLoadingMoreSampleTaken = false,
    this.departments = const [],
    this.waitingForAdmissionPatients = const [],
    this.sampleTakenPatients = const [],
    this.hasReachedMaxWaitingForAdmission = false,
    this.hasReachedMaxSampleTaken = false,
    this.currentWaitingForAdmissionPage = 1,
    this.currentSampleTakenPage = 1,
    this.errorMessage,
  });

  PatientAdmissionsState copyWith({
    bool? isLoadingDepartments,
    bool? isLoadingWaitingForAdmission,
    bool? isLoadingSampleTaken,
    bool? isLoadingMoreWaitingForAdmission,
    bool? isLoadingMoreSampleTaken,
    List<DepartmentParameter>? departments,
    List<PatientVisit>? waitingForAdmissionPatients,
    List<PatientVisit>? sampleTakenPatients,
    bool? hasReachedMaxWaitingForAdmission,
    bool? hasReachedMaxSampleTaken,
    int? currentWaitingForAdmissionPage,
    int? currentSampleTakenPage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientAdmissionsState(
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      isLoadingWaitingForAdmission:
          isLoadingWaitingForAdmission ?? this.isLoadingWaitingForAdmission,
      isLoadingSampleTaken: isLoadingSampleTaken ?? this.isLoadingSampleTaken,
      isLoadingMoreWaitingForAdmission: isLoadingMoreWaitingForAdmission ??
          this.isLoadingMoreWaitingForAdmission,
      isLoadingMoreSampleTaken:
          isLoadingMoreSampleTaken ?? this.isLoadingMoreSampleTaken,
      departments: departments ?? this.departments,
      waitingForAdmissionPatients:
          waitingForAdmissionPatients ?? this.waitingForAdmissionPatients,
      sampleTakenPatients: sampleTakenPatients ?? this.sampleTakenPatients,
      hasReachedMaxWaitingForAdmission: hasReachedMaxWaitingForAdmission ??
          this.hasReachedMaxWaitingForAdmission,
      hasReachedMaxSampleTaken:
          hasReachedMaxSampleTaken ?? this.hasReachedMaxSampleTaken,
      currentWaitingForAdmissionPage:
          currentWaitingForAdmissionPage ?? this.currentWaitingForAdmissionPage,
      currentSampleTakenPage:
          currentSampleTakenPage ?? this.currentSampleTakenPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoadingDepartments,
        isLoadingWaitingForAdmission,
        isLoadingSampleTaken,
        isLoadingMoreWaitingForAdmission,
        isLoadingMoreSampleTaken,
        departments,
        waitingForAdmissionPatients,
        sampleTakenPatients,
        hasReachedMaxWaitingForAdmission,
        hasReachedMaxSampleTaken,
        currentWaitingForAdmissionPage,
        currentSampleTakenPage,
        errorMessage,
      ];
}
