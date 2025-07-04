import 'package:equatable/equatable.dart';
import '../../data/models/patient_models.dart';

class SampleDetailsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Sample> samples;
  final List<TestDetails> testDetails;

  const SampleDetailsState({
    this.isLoading = false,
    this.errorMessage,
    this.samples = const [],
    this.testDetails = const [],
  });

  SampleDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Sample>? samples,
    List<TestDetails>? testDetails,
    bool clearError = false,
  }) {
    return SampleDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      samples: samples ?? this.samples,
      testDetails: testDetails ?? this.testDetails,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, samples, testDetails];
}
