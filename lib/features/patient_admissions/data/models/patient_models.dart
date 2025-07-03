import 'package:flutter/material.dart';

class PatientInfo {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final int age;
  final String object;
  final String status;
  final Color statusColor;
  final List<SampleInfo> samples;

  PatientInfo({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.age,
    required this.object,
    required this.status,
    required this.statusColor,
    this.samples = const [],
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
