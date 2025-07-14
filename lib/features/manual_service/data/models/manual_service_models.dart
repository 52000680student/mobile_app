import 'package:mobile_app/core/utils/json_parsing_utils.dart';
import 'dart:convert'; // Added for jsonDecode
import '../../../patient_admissions/data/models/patient_models.dart'; // Added for Sample model

/// Model for Patient search API response
class PatientSearchResponse {
  final List<PatientSearchResult> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  PatientSearchResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PatientSearchResponse.fromJson(Map<String, dynamic> json) {
    return PatientSearchResponse(
      data: (json['data'] as List?)
              ?.map((item) =>
                  PatientSearchResult.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: JsonParsingUtils.parseIntSafely(json['page']) ?? 1,
      size: JsonParsingUtils.parseIntSafely(json['size']) ?? 0,
      totalElements:
          JsonParsingUtils.parseIntSafely(json['totalElements']) ?? 0,
      totalPages: JsonParsingUtils.parseIntSafely(json['totalPages']) ?? 0,
      last: JsonParsingUtils.parseBoolSafely(json['last']) ?? true,
    );
  }
}

/// Model for individual patient from search API
class PatientSearchResult {
  final int id;
  final String patientId;
  final String name;
  final String dob;
  final String dobName;
  final String gender;
  final String genderName;
  final String? remark;
  final String? phoneNumber;
  final String address;
  final String fullAddress;
  final String? nationalId;
  final String ward;
  final String wardName;
  final String district;
  final String districtName;
  final String province;
  final String provinceName;
  final String country;
  final String countryName;
  final int managementCompanyId;
  final String profileName;
  final String createdDate;
  final String? fields;
  final String? contactFields;
  final String? addressFields;
  final String? furtherValue;

  PatientSearchResult({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dob,
    required this.dobName,
    required this.gender,
    required this.genderName,
    this.remark,
    this.phoneNumber,
    required this.address,
    required this.fullAddress,
    this.nationalId,
    required this.ward,
    required this.wardName,
    required this.district,
    required this.districtName,
    required this.province,
    required this.provinceName,
    required this.country,
    required this.countryName,
    required this.managementCompanyId,
    required this.profileName,
    required this.createdDate,
    this.fields,
    this.contactFields,
    this.addressFields,
    this.furtherValue,
  });

  factory PatientSearchResult.fromJson(Map<String, dynamic> json) {
    return PatientSearchResult(
      id: JsonParsingUtils.parseIntSafely(json['id']) ?? 0,
      patientId: json['patientId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      dobName: json['dobName']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      genderName: json['genderName']?.toString() ?? '',
      remark: json['remark']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      address: json['address']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? '',
      nationalId: json['nationalId']?.toString(),
      ward: json['ward']?.toString() ?? '',
      wardName: json['wardName']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      districtName: json['districtName']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      provinceName: json['provinceName']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      managementCompanyId:
          JsonParsingUtils.parseIntSafely(json['managementCompanyId']) ?? 0,
      profileName: json['profileName']?.toString() ?? '',
      createdDate: json['createdDate']?.toString() ?? '',
      fields: json['fields']?.toString(),
      contactFields: json['contactFields']?.toString(),
      addressFields: json['addressFields']?.toString(),
      furtherValue: json['furtherValue']?.toString(),
    );
  }

  /// Parse date of birth to DateTime
  DateTime? getParsedDob() {
    try {
      return DateTime.parse(dob);
    } catch (e) {
      return null;
    }
  }

  /// Calculate age from date of birth
  int calculateAge() {
    final birthDate = getParsedDob();
    if (birthDate == null) return 0;

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// Model for Department API response
class DepartmentResponse {
  final List<Department> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  DepartmentResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      data: (json['data'] as List?)
              ?.map((item) => Department.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: JsonParsingUtils.parseIntSafely(json['page']) ?? 1,
      size: JsonParsingUtils.parseIntSafely(json['size']) ?? 0,
      totalElements:
          JsonParsingUtils.parseIntSafely(json['totalElements']) ?? 0,
      totalPages: JsonParsingUtils.parseIntSafely(json['totalPages']) ?? 0,
      last: JsonParsingUtils.parseBoolSafely(json['last']) ?? true,
    );
  }
}

/// Model for individual department
class Department {
  final int id;
  final int companyId;
  final String companyName;
  final String name;
  final String managedCode;
  final int parentDepartmentId;
  final String type;
  final String typeName;
  final String remark;
  final bool status;
  final int countUser;

  Department({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.name,
    required this.managedCode,
    required this.parentDepartmentId,
    required this.type,
    required this.typeName,
    required this.remark,
    required this.status,
    required this.countUser,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: JsonParsingUtils.parseIntSafely(json['id']) ?? 0,
      companyId: JsonParsingUtils.parseIntSafely(json['companyId']) ?? 0,
      companyName: json['companyName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      managedCode: json['managedCode']?.toString() ?? '',
      parentDepartmentId:
          JsonParsingUtils.parseIntSafely(json['parentDepartmentId']) ?? 0,
      type: json['type']?.toString() ?? '',
      typeName: json['typeName']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      status: JsonParsingUtils.parseBoolSafely(json['status']) ?? false,
      countUser: JsonParsingUtils.parseIntSafely(json['countUser']) ?? 0,
    );
  }
}

/// Model for Service Parameter API response (L125 codes)
class ServiceParameter {
  final int id;
  final int parameterId;
  final String code;
  final String value;
  final int sequence;
  final String languageCode;
  final String languageName;
  final String message;
  final String? group;
  final bool inUse;
  final bool isDefault;

  ServiceParameter({
    required this.id,
    required this.parameterId,
    required this.code,
    required this.value,
    required this.sequence,
    required this.languageCode,
    required this.languageName,
    required this.message,
    this.group,
    required this.inUse,
    required this.isDefault,
  });

  factory ServiceParameter.fromJson(Map<String, dynamic> json) {
    return ServiceParameter(
      id: JsonParsingUtils.parseIntSafely(json['id']) ?? 0,
      parameterId: JsonParsingUtils.parseIntSafely(json['parameterId']) ?? 0,
      code: json['code']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      sequence: JsonParsingUtils.parseIntSafely(json['sequence']) ?? 0,
      languageCode: json['languageCode']?.toString() ?? '',
      languageName: json['languageName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      group: json['group']?.toString(),
      inUse: JsonParsingUtils.parseBoolSafely(json['inUse']) ?? false,
      isDefault: JsonParsingUtils.parseBoolSafely(json['isDefault']) ?? false,
    );
  }
}

/// Model for Test Service API response
class TestServiceResponse {
  final List<TestService> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  TestServiceResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory TestServiceResponse.fromJson(Map<String, dynamic> json) {
    return TestServiceResponse(
      data: (json['data'] as List?)
              ?.map(
                  (item) => TestService.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      page: JsonParsingUtils.parseIntSafely(json['page']) ?? 1,
      size: JsonParsingUtils.parseIntSafely(json['size']) ?? 0,
      totalElements:
          JsonParsingUtils.parseIntSafely(json['totalElements']) ?? 0,
      totalPages: JsonParsingUtils.parseIntSafely(json['totalPages']) ?? 0,
      last: JsonParsingUtils.parseBoolSafely(json['last']) ?? true,
    );
  }
}

/// Model for individual test service
class TestService {
  final int id;
  final String testCode;
  final String testName;
  final String? shortName;
  final String? quickCode;
  final String? customName;
  final String profileId;
  final String profileName;
  final String code;
  final int type;
  final String? typeName;
  final String sampleType;
  final String sampleTypeName;
  final String category;
  final String categoryName;
  final int displayOrder;
  final String? tags;
  final String? remark;
  final bool inUse;
  final int testConfigCount;
  final String? testMethod;
  final bool iso;
  final String? vendorCode;
  final String? vendorName;
  final int? vendorId;
  final int createdBy;
  final String createdDate;
  final int updatedBy;
  final String updatedDate;
  final String? additionalInfos;
  final String reportTypeName;
  final String reportType;
  final String unit;
  final String? mbNumTypeName;
  final String? mbNumType;
  final String? subSID;
  final bool isQC;

  TestService({
    required this.id,
    required this.testCode,
    required this.testName,
    this.shortName,
    this.quickCode,
    this.customName,
    required this.profileId,
    required this.profileName,
    required this.code,
    required this.type,
    this.typeName,
    required this.sampleType,
    required this.sampleTypeName,
    required this.category,
    required this.categoryName,
    required this.displayOrder,
    this.tags,
    this.remark,
    required this.inUse,
    required this.testConfigCount,
    this.testMethod,
    required this.iso,
    this.vendorCode,
    this.vendorName,
    this.vendorId,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    this.additionalInfos,
    required this.reportTypeName,
    required this.reportType,
    required this.unit,
    this.mbNumTypeName,
    this.mbNumType,
    this.subSID,
    required this.isQC,
  });

  factory TestService.fromJson(Map<String, dynamic> json) {
    return TestService(
      id: JsonParsingUtils.parseIntSafely(json['id']) ?? 0,
      testCode: json['testCode']?.toString() ?? '',
      testName: json['testName']?.toString() ?? '',
      shortName: json['shortName']?.toString(),
      quickCode: json['quickCode']?.toString(),
      customName: json['customName']?.toString(),
      profileId: json['profileId']?.toString() ?? '',
      profileName: json['profileName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: JsonParsingUtils.parseIntSafely(json['type']) ?? 0,
      typeName: json['typeName']?.toString(),
      sampleType: json['sampleType']?.toString() ?? '',
      sampleTypeName: json['sampleTypeName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      displayOrder: JsonParsingUtils.parseIntSafely(json['displayOrder']) ?? 0,
      tags: json['tags']?.toString(),
      remark: json['remark']?.toString(),
      inUse: JsonParsingUtils.parseBoolSafely(json['inUse']) ?? false,
      testConfigCount:
          JsonParsingUtils.parseIntSafely(json['testConfigCount']) ?? 0,
      testMethod: json['testMethod']?.toString(),
      iso: JsonParsingUtils.parseBoolSafely(json['iso']) ?? false,
      vendorCode: json['vendorCode']?.toString(),
      vendorName: json['vendorName']?.toString(),
      vendorId: JsonParsingUtils.parseIntSafely(json['vendorId']),
      createdBy: JsonParsingUtils.parseIntSafely(json['createdBy']) ?? 0,
      createdDate: json['createdDate']?.toString() ?? '',
      updatedBy: JsonParsingUtils.parseIntSafely(json['updatedBy']) ?? 0,
      updatedDate: json['updatedDate']?.toString() ?? '',
      additionalInfos: json['additionalInfos']?.toString(),
      reportTypeName: json['reportTypeName']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      mbNumTypeName: json['mbNumTypeName']?.toString(),
      mbNumType: json['mbNumType']?.toString(),
      subSID: json['subSID']?.toString(),
      isQC: JsonParsingUtils.parseBoolSafely(json['isQC']) ?? false,
    );
  }
}

/// Model for sample item to be used in samples tab
class SampleItem {
  final String name;
  final String type;
  final String serialNumber;
  final String sid;
  final DateTime? collectionTime;
  final int? collectionUserId;

  SampleItem({
    required this.name,
    required this.type,
    required this.serialNumber,
    required this.sid,
    this.collectionTime,
    this.collectionUserId,
  });

  factory SampleItem.fromTestService(TestService testService) {
    return SampleItem(
      name: testService.sampleTypeName,
      type: testService.sampleType,
      serialNumber: '3', // Default as mentioned in Todo.txt
      sid: 'Auto', // Default as mentioned in Todo.txt
    );
  }
}

/// Model for Manual Service Request API
class ManualServiceRequest {
  final String requestDate;
  final String requestid;
  final String alternateId;
  final String patientId;
  final String medicalId;
  final String fullName;
  final String serviceType;
  final String dob;
  final int physicianId;
  final String physicianName;
  final String gender;
  final String departmentId;
  final String phone;
  final String diagnosis;
  final String address;
  final String? resultTime;
  final String email;
  final String remark;
  final int patient;
  final int companyId;
  final String patientGroupType;
  final int profileId;
  final List<ManualServiceRequestTest> tests;
  final List<dynamic> profiles; // Empty array for now
  final SidParam sidParam;
  final IndividualValues individualValues;
  final List<ManualServiceRequestSample> samples;
  final bool isCollected;
  final bool isReceived;

  ManualServiceRequest({
    required this.requestDate,
    required this.requestid,
    required this.alternateId,
    required this.patientId,
    required this.medicalId,
    required this.fullName,
    required this.serviceType,
    required this.dob,
    required this.physicianId,
    required this.physicianName,
    required this.gender,
    required this.departmentId,
    required this.phone,
    required this.diagnosis,
    required this.address,
    this.resultTime,
    required this.email,
    required this.remark,
    required this.patient,
    required this.companyId,
    required this.patientGroupType,
    required this.profileId,
    required this.tests,
    required this.profiles,
    required this.sidParam,
    required this.individualValues,
    required this.samples,
    required this.isCollected,
    required this.isReceived,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestDate': requestDate,
      'requestid': requestid,
      'alternateId': alternateId,
      'patientId': patientId,
      'medicalId': medicalId,
      'fullName': fullName,
      'serviceType': serviceType,
      'dob': dob,
      'physicianId': physicianId,
      'physicianName': physicianName,
      'gender': gender,
      'departmentId': departmentId,
      'phone': phone,
      'diagnosis': diagnosis,
      'address': address,
      'resultTime': resultTime,
      'email': email,
      'remark': remark,
      'patient': patient,
      'companyId': companyId,
      'patientGroupType': patientGroupType,
      'ProfileId': profileId,
      'tests': tests.map((test) => test.toJson()).toList(),
      'profiles': profiles,
      'sidParam': sidParam.toJson(),
      'individualValues': individualValues.toJson(),
      'samples': samples.map((sample) => sample.toJson()).toList(),
      'isCollected': isCollected,
      'isReceived': isReceived,
    };
  }
}

/// Model for test in manual service request
class ManualServiceRequestTest {
  final String testCode;
  final String testCategory;
  final String sampleType;
  final int sID;
  final String subSID;

  ManualServiceRequestTest({
    required this.testCode,
    required this.testCategory,
    required this.sampleType,
    required this.sID,
    required this.subSID,
  });

  Map<String, dynamic> toJson() {
    return {
      'testCode': testCode,
      'testCategory': testCategory,
      'sampleType': sampleType,
      'sID': sID,
      'subSID': subSID,
    };
  }

  factory ManualServiceRequestTest.fromTestService(TestService testService) {
    return ManualServiceRequestTest(
      testCode: testService.testCode,
      testCategory: testService.category,
      sampleType: testService.sampleType,
      sID: 0,
      subSID: "",
    );
  }
}

/// Model for SID parameters
class SidParam {
  final String fullDate;
  final String year;

  SidParam({
    required this.fullDate,
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'FullDate': fullDate,
      'Year': year,
    };
  }

  factory SidParam.current() {
    final now = DateTime.now();
    // Format: ddmmyy
    final fullDate =
        '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';
    final year = now.year.toString();

    return SidParam(
      fullDate: fullDate,
      year: year,
    );
  }
}

/// Model for individual values in manual service request
class IndividualValues {
  final String patientId;
  final int companyId;
  final String fullName;
  final String familyName;
  final String dob;
  final String gender;
  final String pin;
  final ContactInfo contact;
  final AddressInfo address;
  final int profileId;

  IndividualValues({
    required this.patientId,
    required this.companyId,
    required this.fullName,
    required this.familyName,
    required this.dob,
    required this.gender,
    required this.pin,
    required this.contact,
    required this.address,
    required this.profileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'PatientId': patientId,
      'companyId': companyId,
      'FullName': fullName,
      'FamilyName': familyName,
      'DOB': dob,
      'Gender': gender,
      'PIN': pin,
      'Contact': contact.toJson(),
      'Address': address.toJson(),
      'ProfileId': profileId,
    };
  }

  factory IndividualValues.fromPatientSearchResult(
      PatientSearchResult patient) {
    return IndividualValues(
      patientId: patient.patientId,
      companyId: 1,
      fullName: patient.name,
      familyName: patient.name,
      dob: patient.dob,
      gender: patient.gender,
      pin: "",
      contact: ContactInfo(
        phoneNumber: patient.phoneNumber ?? "",
        emailAddress: "",
      ),
      address: AddressInfo(
        address: patient.address,
      ),
      profileId: 3,
    );
  }
}

/// Model for contact information
class ContactInfo {
  final String phoneNumber;
  final String emailAddress;

  ContactInfo({
    required this.phoneNumber,
    required this.emailAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'PhoneNumber': phoneNumber,
      'EmailAddress': emailAddress,
    };
  }
}

/// Model for address information
class AddressInfo {
  final String address;

  AddressInfo({
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'Address': address,
    };
  }
}

/// Model for sample in manual service request
class ManualServiceRequestSample {
  final String sampleType;
  final String sampleColor;
  final String numberOfLabels;
  final String quality;
  final int? collectorUserId;
  final int sID;
  final String subID;
  final int? receiverUserId;
  final String? subSID;

  ManualServiceRequestSample({
    required this.sampleType,
    required this.sampleColor,
    required this.numberOfLabels,
    required this.quality,
    this.collectorUserId,
    required this.sID,
    required this.subID,
    this.receiverUserId,
    this.subSID,
  });

  Map<String, dynamic> toJson() {
    return {
      'sampleType': sampleType,
      'sampleColor': sampleColor,
      'numberOfLabels': numberOfLabels,
      'quality': quality,
      'collectorUserId': collectorUserId,
      'sID': sID,
      'subID': subID,
      'ReceiverUserId': receiverUserId,
      'subSID': subSID,
    };
  }

  factory ManualServiceRequestSample.fromSampleItem(
      SampleItem sampleItem, bool isCollected, int? loggedInUserId) {
    return ManualServiceRequestSample(
      sampleType: sampleItem.type,
      sampleColor: "",
      numberOfLabels: sampleItem.serialNumber,
      quality: "",
      collectorUserId: isCollected ? loggedInUserId : null,
      sID: 0,
      subID: "",
      receiverUserId: null,
      subSID: null,
    );
  }
}

/// Response model for manual service request API
class ManualServiceRequestResponse {
  final int id;

  ManualServiceRequestResponse({
    required this.id,
  });

  factory ManualServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    return ManualServiceRequestResponse(
      id: JsonParsingUtils.parseIntSafely(json['id']) ?? 0,
    );
  }
}

/// Query parameters for patient search API
class PatientSearchQueryParams {
  final String? query;
  final int size;
  final int page;

  PatientSearchQueryParams({
    this.query,
    this.size = 5,
    this.page = 1,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'size': size,
      'page': page,
    };

    if (query != null && query!.isNotEmpty) {
      params['q'] = query;
    }

    return params;
  }
}

/// Query parameters for department search API
class DepartmentQueryParams {
  final int size;
  final int page;

  DepartmentQueryParams({
    this.size = 0,
    this.page = 1,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'size': size,
      'page': page,
    };
  }
}

/// Query parameters for test service API
class TestServiceQueryParams {
  final int size;
  final int page;
  final bool inUse;

  TestServiceQueryParams({
    this.size = 0,
    this.page = 1,
    this.inUse = true,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'size': size,
      'page': page,
      'inUse': inUse,
    };
  }
}

/// Doctor model for manual service
class Doctor {
  final int id;
  final String name;
  final String? title;
  final String? department;
  final String? quickCode;
  final bool isActive;
  final String? profileName;
  final DateTime? createdDate;

  const Doctor({
    required this.id,
    required this.name,
    this.title,
    this.department,
    this.quickCode,
    this.isActive = true,
    this.profileName,
    this.createdDate,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Parse furtherValue JSON to extract additional fields
    String? title;
    String? department;
    String? quickCode;
    bool isActive = true;

    try {
      final furtherValueString = json['furtherValue'] as String?;
      if (furtherValueString != null && furtherValueString.isNotEmpty) {
        final furtherValueList = jsonDecode(furtherValueString) as List;
        for (final item in furtherValueList) {
          final fieldCode = item['FieldCode'] as String?;
          final value = item['FurtherValue'] as String?;

          switch (fieldCode) {
            case 'Title':
              title = value;
              break;
            case 'Department':
              department = value;
              break;
            case 'DoctorQuickCode':
              quickCode = value;
              break;
            case 'Active':
              isActive = value?.toLowerCase() == 'true';
              break;
          }
        }
      }
    } catch (e) {
      // If parsing fails, use default values
    }

    return Doctor(
      id: json['id'] as int,
      name: (json['name'] as String? ?? '').trim(),
      title: title,
      department: department,
      quickCode: quickCode,
      isActive: isActive,
      profileName: json['profileName'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'department': department,
      'quickCode': quickCode,
      'isActive': isActive,
      'profileName': profileName,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Doctor API response wrapper
class DoctorResponse {
  final List<Doctor> data;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  const DoctorResponse({
    required this.data,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    return DoctorResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Doctor.fromJson(item as Map<String, dynamic>))
              .where((doctor) => doctor.isActive) // Only include active doctors
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((doctor) => doctor.toJson()).toList(),
      'page': page,
      'size': size,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'last': last,
    };
  }
}

/// Doctor query parameters
class DoctorQueryParams {
  final String query;
  final int size;
  final int profileId;

  const DoctorQueryParams({
    this.query = '',
    this.size = 0,
    this.profileId = 7, // Profile ID for doctors
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'q': query,
      'size': size,
      'profileId': profileId,
    };
  }
}

/// Barcode print request parameters for /api/la/v1/global/reports/101/print
class BarcodePrintRequest {
  final int sid;
  final int? subSID;
  final String requestDate;
  final String sampleType;
  final String page;

  const BarcodePrintRequest({
    required this.sid,
    this.subSID,
    required this.requestDate,
    required this.sampleType,
    this.page = 'B1',
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'SID': sid,
      'RequestDate': requestDate,
      'SampleType': sampleType,
      'Page': page,
    };

    if (subSID != null) {
      params['SubSID'] = subSID;
    }

    return params;
  }
}

/// Barcode print response from /api/la/v1/global/reports/101/print
class BarcodePrintResponse {
  final String reportUUID;
  final String reportUrl;

  const BarcodePrintResponse({
    required this.reportUUID,
    required this.reportUrl,
  });

  factory BarcodePrintResponse.fromJson(Map<String, dynamic> json) {
    return BarcodePrintResponse(
      reportUUID: json['reportUUID'] as String? ?? '',
      reportUrl: json['reportUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportUUID': reportUUID,
      'reportUrl': reportUrl,
    };
  }
}

/// Barcode data model for sample comparison
class BarcodeData {
  final int sid;
  final int? subSID;
  final String requestDate;
  final String sampleType;
  final String page;

  const BarcodeData({
    required this.sid,
    this.subSID,
    required this.requestDate,
    required this.sampleType,
    this.page = 'B1',
  });

  /// Create BarcodeData from Sample and manual service data
  factory BarcodeData.fromSample({
    required Sample sample,
    required String requestDate,
    String page = 'B1',
  }) {
    return BarcodeData(
      sid: sample.sid,
      subSID: sample.subSID,
      requestDate: requestDate,
      sampleType: sample.sampleType,
      page: page,
    );
  }

  /// Convert to BarcodePrintRequest
  BarcodePrintRequest toBarcodePrintRequest() {
    return BarcodePrintRequest(
      sid: sid,
      subSID: subSID,
      requestDate: requestDate,
      sampleType: sampleType,
      page: page,
    );
  }
}
