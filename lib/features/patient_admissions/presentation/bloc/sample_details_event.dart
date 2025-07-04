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
