import 'package:equatable/equatable.dart';

abstract class SampleDetailsEvent extends Equatable {
  const SampleDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSampleDetails extends SampleDetailsEvent {
  final int id;

  const LoadSampleDetails({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateSample extends SampleDetailsEvent {
  final int requestId;
  final Map<String, dynamic> sampleData;

  const UpdateSample({required this.requestId, required this.sampleData});

  @override
  List<Object?> get props => [requestId, sampleData];
}
