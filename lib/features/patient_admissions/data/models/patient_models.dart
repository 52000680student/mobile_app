import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/patient_states.dart';

/// Model for department parameter API response
class DepartmentParameter {
  final int id;
  final int parameterId;
  final String code;
  final int sequence;
  final String languageCode;
  final String languageName;
  final String message;
  final String? group;
  final bool inUse;
  final bool isDefault;

  DepartmentParameter({
    required this.id,
    required this.parameterId,
    required this.code,
    required this.sequence,
    required this.languageCode,
    required this.languageName,
    required this.message,
    this.group,
    required this.inUse,
    required this.isDefault,
  });

  factory DepartmentParameter.fromJson(Map<String, dynamic> json) {
    return DepartmentParameter(
      id: json['id'],
      parameterId: json['parameterId'],
      code: json['code'],
      sequence: json['sequence'],
      languageCode: json['languageCode'],
      languageName: json['languageName'],
      message: json['message'],
      group: json['group'],
      inUse: json['inUse'],
      isDefault: json['isDefault'],
    );
  }
}

/// Model for API patient visit response
class PatientVisitResponse {
  final List<PatientVisit> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  PatientVisitResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PatientVisitResponse.fromJson(Map<String, dynamic> json) {
    return PatientVisitResponse(
      data: (json['data'] as List)
          .map((item) => PatientVisit.fromJson(item))
          .toList(),
      page: json['page'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      last: json['last'],
    );
  }
}

/// Model for individual patient visit from API
class PatientVisit {
  final int id;
  final String sid;
  final DateTime requestDate;
  final String patientId;
  final String? familyName;
  final String? givenName;
  final String patientName;
  final String alternateId;
  final int state;
  final String stateName;
  final String sampleIds;
  final int requestId;
  final String serviceType;
  final String dob;
  final String? groupCode;
  final int resultId;
  final String medicalId;
  final int stateBookmark;
  final bool emergency;
  final String createdDate;

  PatientVisit({
    required this.id,
    required this.sid,
    required this.requestDate,
    required this.patientId,
    this.familyName,
    this.givenName,
    required this.patientName,
    required this.alternateId,
    required this.state,
    required this.stateName,
    required this.sampleIds,
    required this.requestId,
    required this.serviceType,
    required this.dob,
    this.groupCode,
    required this.resultId,
    required this.medicalId,
    required this.stateBookmark,
    required this.emergency,
    required this.createdDate,
  });

  factory PatientVisit.fromJson(Map<String, dynamic> json) {
    // Parse requestDate from string to DateTime
    DateTime parseRequestDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is DateTime) return date;
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          // Try parsing different date formats
          try {
            final parts = date.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              return DateTime(year, month, day);
            }
          } catch (_) {}
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return PatientVisit(
      id: json['id'],
      sid: json['sid'],
      requestDate: parseRequestDate(json['requestDate']),
      patientId: json['patientId'],
      familyName: json['familyName'],
      givenName: json['givenName'],
      patientName: json['patientName'],
      alternateId: json['alternateId'],
      state: json['state'],
      stateName: json['stateName'],
      sampleIds: json['sampleIds'],
      requestId: json['requestId'],
      serviceType: json['serviceType'],
      dob: json['dob'],
      groupCode: json['groupCode'],
      resultId: json['resultId'],
      medicalId: json['medicalId'],
      stateBookmark: json['stateBookmark'],
      emergency: json['emergency'],
      createdDate: json['createdDate'],
    );
  }

  String getSidFromSampleIds() {
    String sid = '';
    try {
      final sampleIdsList = jsonDecode(sampleIds) as List?;
      if (sampleIdsList != null && sampleIdsList.isNotEmpty) {
        final firstSample = sampleIdsList[0] as Map<String, dynamic>?;
        if (firstSample != null && firstSample.containsKey('SID')) {
          sid = firstSample['SID']?.toString() ?? '';
          sid = sid.length == 9 ? '0$sid' : sid;
        }
      }
    } catch (e) {
      sid = '';
    }
    return sid;
  }

  /// Convert to legacy PatientInfo model for UI compatibility
  PatientInfo toPatientInfo() {
    DateTime birthDate;
    try {
      // Parse date in format "09/08/1996 00:00:00"
      final dateParts = dob.split(' ')[0].split('/');
      if (dateParts.length == 3) {
        birthDate = DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[0]), // day
        );
      } else {
        birthDate = DateTime.now();
      }
    } catch (e) {
      birthDate = DateTime.now();
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    // Determine gender from name or set default
    String gender = 'Không xác định';
    if (patientName.toLowerCase().contains('nam')) {
      gender = 'Nam';
    } else if (patientName.toLowerCase().contains('nữ') ||
        patientName.toLowerCase().contains('thị')) {
      gender = 'Nữ';
    }

    // Get localized state key
    final stateKey = PatientStates.getStateKey(stateName);

    // Determine status color based on state name
    Color statusColor = _getStatusColor(stateName);

    return PatientInfo(
      id: id,
      patientId: patientId,
      sid: getSidFromSampleIds(),
      name: patientName,
      birthDate: birthDate,
      requestDate: requestDate,
      gender: gender,
      age: age,
      object: serviceType,
      status: stateKey, // Use localization key instead of raw state
      statusColor: statusColor,
      rawState: stateName, // Keep original state for reference
      requestId: requestId,
    );
  }

  /// Get status color based on state name
  Color _getStatusColor(String stateName) {
    switch (stateName.toLowerCase()) {
      case 'draft':
        return const Color(0xFF9E9E9E); // Gray for draft
      case 'submitted':
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue for received/submitted
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFF44336); // Red for cancelled
      case 'collected':
        return const Color(0xFF4CAF50); // Green for collected
      case 'delivered':
      case 'received':
        return const Color(0xFF00BCD4); // Cyan for delivered/received
      case 'on hold':
      case 'onhold':
        return const Color(0xFFFF9800); // Orange for on hold
      case 'in process':
      case 'inprocess':
        return const Color(0xFF2196F3); // Blue for in process
      case 'completed':
        return const Color(0xFF4CAF50); // Green for completed
      case 'validated':
      case 'approved':
        return const Color(0xFF8BC34A); // Light green for validated/approved
      case 'released':
        return const Color(0xFF3F51B5); // Indigo for released
      case 'signed':
        return const Color(0xFF673AB7); // Deep purple for signed
      default:
        return const Color(0xFF9E9E9E); // Gray for unknown states
    }
  }
}

// Legacy models for UI compatibility
class PatientInfo {
  final int id;
  final String patientId;
  final String sid;
  final String name;
  final DateTime birthDate;
  final DateTime requestDate;
  final String gender;
  final int age;
  final String object;
  final String status; // Localization key
  final Color statusColor;
  final List<SampleInfo> samples;
  final String? rawState; // Original state from API
  final int requestId;

  PatientInfo({
    required this.id,
    required this.patientId,
    required this.sid,
    required this.name,
    required this.birthDate,
    required this.requestDate,
    required this.gender,
    required this.age,
    required this.object,
    required this.status,
    required this.statusColor,
    this.samples = const [],
    this.rawState,
    required this.requestId,
  });
}

class SampleInfo {
  final String id;
  final int number;
  final String type;
  final String timeCollected;
  final String collectedBy;
  final String quality;
  final List<SampleService> services;
  final bool isEnabled;

  SampleInfo({
    required this.id,
    required this.number,
    required this.type,
    required this.timeCollected,
    required this.collectedBy,
    required this.quality,
    required this.services,
    required this.isEnabled,
  });
}

class SampleService {
  final String code;
  final String name;
  final String subCode;
  final String description;

  SampleService({
    required this.code,
    required this.name,
    required this.subCode,
    required this.description,
  });
}

/// Model for Sample API response
class SampleResponse {
  final int id;
  final List<Sample> samples;

  SampleResponse({
    required this.id,
    required this.samples,
  });

  factory SampleResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SampleResponse(
        id: json['id'] as int,
        samples: (json['samples'] as List?)
                ?.map((item) => Sample.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      throw FormatException('Failed to parse SampleResponse: $e. JSON: $json');
    }
  }
}

/// Model for individual sample from API
class Sample {
  final int sampleId;
  final int sid;
  final int? subSID;
  final int requestId;
  final String sampleType;
  final String sampleTypeName;
  final String sampleColor;
  final int numberOfLabels;
  final int? collectorUserId;
  final String? collectionTime;
  final int? receiverUserId;
  final String? receivedTime;
  final String? quality;
  final String? qualityName;
  final String? collectorName;
  final String? receiverName;
  final int state;
  final String requestDate;

  Sample({
    required this.sampleId,
    required this.sid,
    this.subSID,
    required this.requestId,
    required this.sampleType,
    required this.sampleTypeName,
    required this.sampleColor,
    required this.numberOfLabels,
    this.collectorUserId,
    this.collectionTime,
    this.receiverUserId,
    this.receivedTime,
    this.quality,
    this.qualityName,
    this.collectorName,
    this.receiverName,
    required this.state,
    required this.requestDate,
  });

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      sampleId: json['sampleId'] as int,
      sid: json['sid'] as int,
      subSID: json['subSID'] as int?,
      requestId: json['requestId'] as int,
      sampleType: json['sampleType'] as String? ?? '',
      sampleTypeName: json['sampleTypeName'] as String? ?? '',
      sampleColor: json['sampleColor'] as String? ?? '',
      numberOfLabels: json['numberOfLabels'] as int? ?? 0,
      collectorUserId: json['collectorUserId'] as int?,
      collectionTime: json['collectionTime'] as String?,
      receiverUserId: json['receiverUserId'] as int?,
      receivedTime: json['receivedTime'] as String?,
      quality: json['quality'] as String?,
      qualityName: json['qualityName'] as String?,
      collectorName: json['collectorName'] as String?,
      receiverName: json['receiverName'] as String?,
      state: json['state'] as int? ?? 0,
      requestDate: json['requestDate'] as String? ?? '',
    );
  }

  /// Get status name based on state value
  String getStateName() {
    switch (state) {
      case 0:
        return 'Draft';
      case 1:
        return 'Submitted';
      case 2:
        return 'Canceled';
      case 3:
        return 'Collected';
      case 4:
        return 'Delivered';
      case 5:
        return 'Received';
      case 6:
        return 'OnHold';
      case 61:
        return 'RDS';
      case 7:
        return 'InProcess';
      case 8:
        return 'Completed';
      case 9:
        return 'Confirmed';
      case 90:
        return 'Validated';
      case 99:
        return 'Released';
      default:
        return 'Unknown';
    }
  }

  /// Get localized status key based on state value
  String getStateKey() {
    switch (state) {
      case 0:
        return 'patientStateDraft';
      case 1:
        return 'patientStateSubmitted';
      case 2:
        return 'patientStateCanceled';
      case 3:
        return 'patientStateCollected';
      case 4:
        return 'patientStateDelivered';
      case 5:
        return 'patientStateReceived';
      case 6:
        return 'patientStateOnHold';
      case 61:
        return 'patientStateSubmitted'; // RDS maps to submitted
      case 7:
        return 'patientStateInProcess';
      case 8:
        return 'patientStateCompleted';
      case 9:
        return 'patientStateConfirmed';
      case 90:
        return 'patientStateValidated';
      case 99:
        return 'patientStateReleased';
      default:
        return 'patientStateDraft';
    }
  }

  /// Get status color based on state
  Color getStatusColor() {
    switch (state) {
      case 0:
        return const Color(0xFF9E9E9E); // Gray for draft
      case 1:
      case 61:
        return const Color(0xFF2196F3); // Blue for submitted/RDS
      case 2:
        return const Color(0xFFF44336); // Red for canceled
      case 3:
        return const Color(0xFF4CAF50); // Green for collected
      case 4:
      case 5:
        return const Color(0xFF00BCD4); // Cyan for delivered/received
      case 6:
        return const Color(0xFFFF9800); // Orange for on hold
      case 7:
        return const Color(0xFF2196F3); // Blue for in process
      case 8:
        return const Color(0xFF4CAF50); // Green for completed
      case 9:
        return const Color(0xFF8BC34A); // Light green for confirmed
      case 90:
        return const Color(0xFF8BC34A); // Light green for validated
      case 99:
        return const Color(0xFF3F51B5); // Indigo for released
      default:
        return const Color(0xFF9E9E9E); // Gray for unknown
    }
  }
}

/// Model for Test from tests API
class Test {
  final int id;
  final int sid;
  final int? subID;
  final String testCode;
  final int createdBy;
  final bool isCreatedBySystem;
  final String testCategory;
  final String testCategoryName;
  final String sampleType;
  final String sampleTypeName;
  final String? profileCode;
  final String state;
  final String sampleState;
  final String effectiveTime;
  final String createdMethod;
  final String? sttgpb;
  final String? sttvs;
  final String? sampleLocation;
  final String reportType;
  final int sampleTypeInSID;
  final int? collectorUserId;
  final String? collectionTime;
  final int? receiverUserId;
  final String? receivedTime;
  final int? deliveryUserId;
  final String? deliveryTime;
  final String collectorUserName;

  Test({
    required this.id,
    required this.sid,
    this.subID,
    required this.testCode,
    required this.createdBy,
    required this.isCreatedBySystem,
    required this.testCategory,
    required this.testCategoryName,
    required this.sampleType,
    required this.sampleTypeName,
    this.profileCode,
    required this.state,
    required this.sampleState,
    required this.effectiveTime,
    required this.createdMethod,
    this.sttgpb,
    this.sttvs,
    this.sampleLocation,
    required this.reportType,
    required this.sampleTypeInSID,
    this.collectorUserId,
    this.collectionTime,
    this.receiverUserId,
    this.receivedTime,
    this.deliveryUserId,
    this.deliveryTime,
    required this.collectorUserName,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'] as int,
      sid: json['sid'] as int,
      subID: json['subID'] as int?,
      testCode: json['testCode'] as String,
      createdBy: json['createdBy'] as int,
      isCreatedBySystem: json['isCreatedBySystem'] as bool,
      testCategory: json['testCategory'] as String,
      testCategoryName: json['testCategoryName'] as String,
      sampleType: json['sampleType'] as String,
      sampleTypeName: json['sampleTypeName'] as String,
      profileCode: json['profileCode'] as String?,
      state: json['state'].toString(),
      sampleState: json['sampleState'].toString(),
      effectiveTime: json['effectiveTime'] as String,
      createdMethod: json['createdMethod'] as String,
      sttgpb: json['sttgpb'] as String?,
      sttvs: json['sttvs'] as String?,
      sampleLocation: json['sampleLocation'] as String?,
      reportType: json['reportType'] as String,
      sampleTypeInSID: json['sampleTypeInSID'] as int,
      collectorUserId: json['collectorUserId'] as int?,
      collectionTime: json['collectionTime'] as String?,
      receiverUserId: json['receiverUserId'] as int?,
      receivedTime: json['receivedTime'] as String?,
      deliveryUserId: json['deliveryUserId'] as int?,
      deliveryTime: json['deliveryTime'] as String?,
      collectorUserName: json['collectorUserName'] as String? ?? '',
    );
  }

  /// Get status name based on state value
  String getStateName() {
    final stateInt = int.tryParse(state) ?? 0;
    switch (stateInt) {
      case 0:
        return 'Draft';
      case 1:
        return 'Submitted';
      case 2:
        return 'Canceled';
      case 3:
        return 'Collected';
      case 4:
        return 'Delivered';
      case 5:
        return 'Received';
      case 6:
        return 'OnHold';
      case 61:
        return 'RDS';
      case 7:
        return 'InProcess';
      case 8:
        return 'Completed';
      case 9:
        return 'Confirmed';
      case 90:
        return 'Validated';
      case 99:
        return 'Released';
      default:
        return 'Unknown';
    }
  }

  /// Get localized status key based on state value
  String getStateKey() {
    final stateInt = int.tryParse(state) ?? 0;
    switch (stateInt) {
      case 0:
        return 'patientStateDraft';
      case 1:
        return 'patientStateSubmitted';
      case 2:
        return 'patientStateCanceled';
      case 3:
        return 'patientStateCollected';
      case 4:
        return 'patientStateDelivered';
      case 5:
        return 'patientStateReceived';
      case 6:
        return 'patientStateOnHold';
      case 61:
        return 'patientStateSubmitted'; // RDS maps to submitted
      case 7:
        return 'patientStateInProcess';
      case 8:
        return 'patientStateCompleted';
      case 9:
        return 'patientStateConfirmed';
      case 90:
        return 'patientStateValidated';
      case 99:
        return 'patientStateReleased';
      default:
        return 'patientStateDraft';
    }
  }

  /// Get status color based on state
  Color getStatusColor() {
    final stateInt = int.tryParse(state) ?? 0;
    switch (stateInt) {
      case 0:
        return const Color(0xFF9E9E9E); // Gray for draft
      case 1:
      case 61:
        return const Color(0xFF2196F3); // Blue for submitted/RDS
      case 2:
        return const Color(0xFFF44336); // Red for canceled
      case 3:
        return const Color(0xFF4CAF50); // Green for collected
      case 4:
      case 5:
        return const Color(0xFF00BCD4); // Cyan for delivered/received
      case 6:
        return const Color(0xFFFF9800); // Orange for on hold
      case 7:
        return const Color(0xFF2196F3); // Blue for in process
      case 8:
        return const Color(0xFF4CAF50); // Green for completed
      case 9:
        return const Color(0xFF8BC34A); // Light green for confirmed
      case 90:
        return const Color(0xFF8BC34A); // Light green for validated
      case 99:
        return const Color(0xFF3F51B5); // Indigo for released
      default:
        return const Color(0xFF9E9E9E); // Gray for unknown
    }
  }
}

/// Model for Test details from GetTestByCode API
class TestDetails {
  final String code;
  final String name;
  final String sampleType;
  final String? sampleTypeName;
  final String? category;
  final Map<String, dynamic>? additionalData;

  TestDetails({
    required this.code,
    required this.name,
    required this.sampleType,
    this.sampleTypeName,
    this.category,
    this.additionalData,
  });

  factory TestDetails.fromJson(Map<String, dynamic> json) {
    return TestDetails(
      code: json['testCode'] ?? '',
      name: json['testName'] ?? '',
      sampleType: json['sampleType'] ?? '',
      sampleTypeName: json['sampleTypeName'],
      category: json['category'],
      additionalData: json,
    );
  }
}

/// Model for API query parameters
class PatientVisitQueryParams {
  final int size;
  final int page;
  final String? start;
  final String? end;
  final String? search;
  final String? serviceType;

  PatientVisitQueryParams({
    this.size = 20,
    this.page = 1,
    this.start,
    this.end,
    this.search,
    this.serviceType,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'size': size,
      'page': page,
    };

    if (start != null) params['start'] = start;
    if (end != null) params['end'] = end;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (serviceType != null && serviceType!.isNotEmpty) {
      params['serviceType'] = serviceType;
    }

    return params;
  }
}
