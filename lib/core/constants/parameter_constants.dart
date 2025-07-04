/// Parameter constants for API calls
class ParameterConstants {
  // Department parameter codes
  static const String departmentParameterCode = 'L125';

  // Default pagination values
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // API endpoints
  static const String parametersEndpoint = '/api/ms/v1/parameters';
  static const String waitingForAdmissionEndpoint =
      '/api/la/v1/requests/waiting/patientVisit';
  static const String sampleTakenEndpoint =
      '/api/la/v1/requests/collected/patientVisit';

  // Department codes mapping
  static const Map<String, String> departmentCodes = {
    'all': '',
    'inpatient': '1', // Nội trú
    'outpatient': 'DD', // Ngoại trú
    'health_check': '4', // KSK
  };

  // Default department selection
  static const String defaultDepartmentCode = '';
  static const String allDepartmentsDisplayName = 'Tất cả khoa';
}

/// API parameter models
class ApiParameters {
  static String getDepartmentCodesUrl(String parameterCode) {
    return '${ParameterConstants.parametersEndpoint}/$parameterCode/codes';
  }
}
