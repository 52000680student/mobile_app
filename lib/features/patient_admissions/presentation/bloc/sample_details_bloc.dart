import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/patient_models.dart';
import '../../domain/usecases/get_request_samples_usecase.dart';
import '../../domain/usecases/get_request_tests_usecase.dart';
import '../../domain/usecases/get_test_by_code_usecase.dart';
import '../../domain/usecases/update_sample_usecase.dart';
import 'sample_details_event.dart';
import 'sample_details_state.dart';

@injectable
class SampleDetailsBloc extends Bloc<SampleDetailsEvent, SampleDetailsState> {
  final GetRequestSamplesUseCase _getRequestSamplesUseCase;
  final GetRequestTestsUseCase _getRequestTestsUseCase;
  final GetTestByCodeUseCase _getTestByCodeUseCase;
  final UpdateSampleUseCase _updateSampleUseCase;

  SampleDetailsBloc(
    this._getRequestSamplesUseCase,
    this._getRequestTestsUseCase,
    this._getTestByCodeUseCase,
    this._updateSampleUseCase,
  ) : super(const SampleDetailsState()) {
    on<LoadSampleDetails>(_onLoadSampleDetails);
    on<UpdateSample>(_onUpdateSample);
  }

  Future<void> _onUpdateSample(
    UpdateSample event,
    Emitter<SampleDetailsState> emit,
  ) async {
    emit(state.copyWith(
        isUpdating: true, clearUpdateError: true, updateSuccessful: false));

    final result =
        await _updateSampleUseCase(event.requestId, event.sampleData);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUpdating: false,
          updateErrorMessage: failure.message,
          updateSuccessful: false,
        ));
      },
      (_) {
        emit(state.copyWith(
          isUpdating: false,
          updateSuccessful: true,
          clearUpdateError: true,
        ));
      },
    );
  }

  Future<void> _onLoadSampleDetails(
    LoadSampleDetails event,
    Emitter<SampleDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Fetch samples first
      final samplesResult = await _getRequestSamplesUseCase(event.id);

      await samplesResult.fold(
        (failure) async {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
        (sampleResponse) async {
          // If sample fetch successful, proceed to fetch tests
          final testsResult = await _getRequestTestsUseCase(event.id);

          await testsResult.fold(
            (failure) async {
              emit(state.copyWith(
                isLoading: false,
                errorMessage: failure.message,
              ));
            },
            (tests) async {
              // For each test, fetch details
              List<TestDetails> allTestDetails = [];

              // Process tests sequentially to avoid race conditions
              for (final test in tests) {
                if (emit.isDone) {
                  return; // Check if event handler is still active
                }

                final detailResult = await _getTestByCodeUseCase(
                    test.testCode, test.effectiveTime);
                detailResult.fold(
                  (failure) => null, // ignore failing test details
                  (detail) => allTestDetails.add(detail),
                );
              }

              if (!emit.isDone) {
                emit(state.copyWith(
                  isLoading: false,
                  samples: sampleResponse.samples,
                  testDetails: allTestDetails,
                  clearError: true,
                ));
              }
            },
          );
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'An unexpected error occurred: $e',
        ));
      }
    }
  }
}
