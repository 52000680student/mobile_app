import 'package:equatable/equatable.dart';
import '../../data/models/patient_models.dart';

class SampleDetailsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Sample> samples;
  final List<TestDetails> testDetails;
  final bool isUpdating;
  final String? updateErrorMessage;
  final bool updateSuccessful;

  const SampleDetailsState({
    this.isLoading = false,
    this.errorMessage,
    this.samples = const [],
    this.testDetails = const [],
    this.isUpdating = false,
    this.updateErrorMessage,
    this.updateSuccessful = false,
  });

  SampleDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Sample>? samples,
    List<TestDetails>? testDetails,
    bool? isUpdating,
    String? updateErrorMessage,
    bool? updateSuccessful,
    bool clearError = false,
    bool clearUpdateError = false,
  }) {
    return SampleDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      samples: samples ?? this.samples,
      testDetails: testDetails ?? this.testDetails,
      isUpdating: isUpdating ?? this.isUpdating,
      updateErrorMessage: clearUpdateError
          ? null
          : updateErrorMessage ?? this.updateErrorMessage,
      updateSuccessful: updateSuccessful ?? this.updateSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        samples,
        testDetails,
        isUpdating,
        updateErrorMessage,
        updateSuccessful
      ];
}
