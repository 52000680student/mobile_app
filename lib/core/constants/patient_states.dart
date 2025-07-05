/// Patient state constants for localization
class PatientStates {
  // Patient state keys for localization
  static const String draft = 'patientStateDraft';
  static const String submitted = 'patientStateSubmitted';
  static const String canceled = 'patientStateCanceled';
  static const String collected = 'patientStateCollected';
  static const String delivered = 'patientStateDelivered';
  static const String received = 'patientStateReceived';
  static const String onHold = 'patientStateOnHold';
  static const String inProcess = 'patientStateInProcess';
  static const String completed = 'patientStateCompleted';
  static const String confirmed = 'patientStateConfirmed';
  static const String validated = 'patientStateValidated';
  static const String released = 'patientStateReleased';
  static const String signed = 'patientStateSigned';
  static const String approved = 'patientStateApproved';

  // Mapping from API state values to localization keys
  static const Map<String, String> stateKeyMap = {
    'Draft': draft,
    'Submitted': submitted,
    'Canceled': canceled,
    'Cancelled': canceled, // Alternative spelling
    'Collected': collected,
    'Delivered': delivered,
    'Received': received,
    'On Hold': onHold,
    'OnHold': onHold, // Alternative format
    'In Process': inProcess,
    'InProcess': inProcess, // Alternative format
    'Completed': completed,
    'Confirmed': confirmed,
    'Validated': validated,
    'Released': released,
    'Signed': signed,
    'Approved': approved,
  };

  // Get localization key for a given state
  static String getStateKey(String state) {
    return stateKeyMap[state] ?? draft; // Default to draft if not found
  }

  // All state keys for easy reference
  static List<String> get allStateKeys => [
        draft,
        submitted,
        canceled,
        collected,
        delivered,
        received,
        onHold,
        inProcess,
        completed,
        confirmed,
        validated,
        released,
        signed,
        approved,
      ];
}

/// Error message constants for localization
class ErrorMessages {
  // API error keys
  static const String networkError = 'errorNetwork';
  static const String serverError = 'errorServer';
  static const String timeoutError = 'errorTimeout';
  static const String unauthorizedError = 'errorUnauthorized';
  static const String forbiddenError = 'errorForbidden';
  static const String notFoundError = 'errorNotFound';
  static const String unknownError = 'errorUnknown';

  // Patient admission specific errors
  static const String fetchDepartmentsError = 'errorFetchDepartments';
  static const String fetchPatientsError = 'errorFetchPatients';
  static const String loadMorePatientsError = 'errorLoadMorePatients';
  static const String invalidDateRangeError = 'errorInvalidDateRange';
  static const String noDataError = 'errorNoData';
  static const String emptySearchError = 'errorEmptySearch';

  // Sample operation specific errors
  static const String sampleUpdateTimeoutError = 'sampleUpdateTimeout';
  static const String sampleCollectionTimeoutError = 'sampleCollectionTimeout';

  // All error keys for easy reference
  static List<String> get allErrorKeys => [
        networkError,
        serverError,
        timeoutError,
        unauthorizedError,
        forbiddenError,
        notFoundError,
        unknownError,
        fetchDepartmentsError,
        fetchPatientsError,
        loadMorePatientsError,
        invalidDateRangeError,
        noDataError,
        emptySearchError,
        sampleUpdateTimeoutError,
        sampleCollectionTimeoutError,
      ];
}
