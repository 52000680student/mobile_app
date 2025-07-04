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
  final String requestDate;
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
    return PatientVisit(
      id: json['id'],
      sid: json['sid'],
      requestDate: json['requestDate'],
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
      gender: gender,
      age: age,
      object: serviceType,
      status: stateKey, // Use localization key instead of raw state
      statusColor: statusColor,
      rawState: stateName, // Keep original state for reference
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
  final String gender;
  final int age;
  final String object;
  final String status; // Localization key
  final Color statusColor;
  final List<SampleInfo> samples;
  final String? rawState; // Original state from API

  PatientInfo({
    required this.id,
    required this.patientId,
    required this.sid,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.age,
    required this.object,
    required this.status,
    required this.statusColor,
    this.samples = const [],
    this.rawState,
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
