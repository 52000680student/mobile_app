import 'package:mobile_app/core/utils/json_parsing_utils.dart';

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
