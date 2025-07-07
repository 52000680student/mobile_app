import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/patient_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../patient_admissions/presentation/bloc/sample_details_bloc.dart';
import '../../../patient_admissions/presentation/bloc/sample_details_event.dart';
import '../../../patient_admissions/presentation/bloc/sample_details_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/dialog_service.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/utils/user_service.dart';

class SampleDetailsModal extends StatefulWidget {
  final PatientInfo patient;
  final bool isFromWaitingForAdmission;
  final VoidCallback? onRefresh;

  const SampleDetailsModal({
    super.key,
    required this.patient,
    this.isFromWaitingForAdmission = false,
    this.onRefresh,
  });

  static void show(BuildContext context, PatientInfo patient,
      {bool isFromWaitingForAdmission = false, VoidCallback? onRefresh}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) {
        return BlocProvider(
          create: (ctx) => getIt<SampleDetailsBloc>()
            ..add(LoadSampleDetails(id: patient.id)),
          child: SampleDetailsModal(
            patient: patient,
            isFromWaitingForAdmission: isFromWaitingForAdmission,
            onRefresh: onRefresh,
          ),
        );
      },
    );
  }

  @override
  State<SampleDetailsModal> createState() => _SampleDetailsModalState();
}

class _SampleDetailsModalState extends State<SampleDetailsModal> {
  // Map to store controllers for each sample
  final Map<int, ValueNotifier<bool>> _switchControllers = {};
  // Map to track which switches have been manually changed by user
  final Map<int, bool> _userModifiedSwitches = {};

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _switchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ValueNotifier<bool> _getOrCreateController(Sample sample) {
    if (!_switchControllers.containsKey(sample.sampleId)) {
      final isCollected =
          sample.state >= 3 || (sample.collectionTime?.isNotEmpty == true);
      _switchControllers[sample.sampleId] = ValueNotifier<bool>(isCollected);
      _userModifiedSwitches[sample.sampleId] =
          false; // Initially not modified by user
    } else {
      // Only update from server data if user hasn't manually modified this switch
      if (!_userModifiedSwitches[sample.sampleId]!) {
        final isCollected =
            sample.state >= 3 || (sample.collectionTime?.isNotEmpty == true);
        _switchControllers[sample.sampleId]!.value = isCollected;
      }
    }
    return _switchControllers[sample.sampleId]!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SampleDetailsBloc, SampleDetailsState>(
      listener: (context, state) {
        if (state.updateSuccessful) {
          // Show success message
          ToastService.showSuccess(context, l10n.recordSampleSuccess);

          // Call refresh callback to update the parent page
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && context.mounted) {
              try {
                // Use the context's navigator to pop the modal
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  // If no pages to pop, try with root navigator
                  Navigator.of(context, rootNavigator: true).pop();
                }
              } catch (e) {
                // Modal was already closed or context is no longer valid
              }
            }
          });
        } else if (state.updateErrorMessage != null) {
          // Show error message only if widget is still mounted
          if (mounted && context.mounted) {
            ToastService.showError(context, state.updateErrorMessage!);
          }
        }
      },
      child: BlocBuilder<SampleDetailsBloc, SampleDetailsState>(
        builder: (context, state) {
          return Material(
            type: MaterialType.transparency,
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            l10n.sampleDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              if (mounted && context.mounted) {
                                _safeCloseModal();
                              }
                            },
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading State
                    if (state.isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    // Error State
                    if (state.errorMessage != null && !state.isLoading)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<SampleDetailsBloc>().add(
                                          LoadSampleDetails(
                                              id: widget.patient.id),
                                        );
                                  },
                                  child: Text(l10n.retry),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Success State with Data
                    if (!state.isLoading && state.errorMessage == null) ...[
                      // Patient Info Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SID: ${widget.patient.sid}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.sampleList(state.samples.length),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sample List with Two-Column Layout
                      Expanded(
                        child: state.samples.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.science_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.errorNoData,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: state.samples.length,
                                itemBuilder: (context, index) {
                                  final sample = state.samples[index];
                                  return _buildSampleCard(
                                      sample, state.testDetails, l10n);
                                },
                              ),
                      ),

                      // Common Record Me Button (only show if from waiting for admission tab and has samples)
                      if (widget.isFromWaitingForAdmission &&
                          state.samples.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildCommonRecordMeButton(
                            context, state.samples, l10n),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSampleCard(
      Sample sample, List<TestDetails> testDetails, AppLocalizations l10n) {
    // Filter test details for this sample (you may need to adjust this logic based on your API response)
    final sampleTests =
        testDetails.where((t) => t.sampleType == sample.sampleType).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample Header with Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.sample(sample.sid),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                // Sample Collection Switch
                _buildSampleCollectionSwitch(sample, l10n),
              ],
            ),

            const SizedBox(height: 16),

            // Two-Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Sample Details
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(l10n.sampleType, sample.sampleTypeName),
                      if (sample.subSID != null)
                        _buildInfoRow(l10n.subSID, sample.subSID.toString()),
                      if (sample.quality?.isNotEmpty == true)
                        _buildInfoRow(l10n.quality, sample.quality!),
                      if (sample.collectorName?.isNotEmpty == true)
                        _buildInfoRow(l10n.collector, sample.collectorName!),
                      if (sample.receiverName?.isNotEmpty == true)
                        _buildInfoRow(l10n.receiver, sample.receiverName!),
                      if (sample.collectionTime?.isNotEmpty == true)
                        _buildInfoRow(l10n.collectionTime,
                            _formatDateTime(sample.collectionTime!)),
                      if (sample.receivedTime?.isNotEmpty == true)
                        _buildInfoRow(l10n.receivedTime,
                            _formatDateTime(sample.receivedTime!)),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right Column - Services
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.services,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (sampleTests.isEmpty)
                        Text(
                          l10n.errorNoData,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        ...sampleTests
                            .map((test) => _buildTestCard(test, l10n)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(TestDetails test, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (test.name.isNotEmpty)
            Text(
              test.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1976D2),
              ),
            ),
          if (test.code.isNotEmpty)
            Text(
              '${l10n.testCode} ${test.code}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
              ),
            ),
          if (test.sampleTypeName?.isNotEmpty == true)
            Text(
              '${l10n.sampleType} ${test.sampleTypeName}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildSampleCollectionSwitch(Sample sample, AppLocalizations l10n) {
    final controller = _getOrCreateController(sample);

    return SizedBox(
      width: 60,
      height: 32,
      child: ValueListenableBuilder<bool>(
        valueListenable: controller,
        builder: (context, value, child) {
          return AdvancedSwitch(
            controller: controller,
            initialValue: controller.value,
            activeColor: const Color(0xFF1976D2),
            inactiveColor: Colors.grey.shade400,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            width: 60.0,
            height: 32.0,
            enabled: widget
                .isFromWaitingForAdmission, // Enable interaction only for waiting for admission tab
            thumb: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? const Color(0xFF1976D2) : Colors.grey.shade400,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  value ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            onChanged: (newValue) {
              // Update the controller value
              controller.value = newValue;

              // Mark this switch as user-modified
              _userModifiedSwitches[sample.sampleId] = true;

              // If from waiting for admission tab, update collectorUserId
              if (widget.isFromWaitingForAdmission) {
                // Update the collectorUserId based on switch state
                // When true, set to logged in user ID, when false, set to null
                if (newValue) {
                  // Get current user ID from token
                  getIt<UserService>()
                      .getCurrentUserIdWithFallback()
                      .then((userId) {
                    // Sample collection status changed for sample ${sample.sampleId}: $newValue, collectorUserId: $userId
                  });
                }
                // You can add logic here to update the sample model if needed
                // For now, just tracking the change
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCommonRecordMeButton(
      BuildContext context, List<Sample> samples, AppLocalizations l10n) {
    return BlocBuilder<SampleDetailsBloc, SampleDetailsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: state.isUpdating
                  ? null
                  : () => _onCommonRecordMePressed(context, samples, l10n),
              icon: state.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.assignment_turned_in),
              label: Text(
                state.isUpdating ? l10n.processing : l10n.recordMe,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Safely close the modal with proper checks
  void _safeCloseModal() {
    if (mounted && context.mounted) {
      try {
        // Check if we can pop from the current navigator
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          // If no pages to pop in current navigator, try with root navigator
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      } catch (e) {
        // Modal was already closed or context is no longer valid
      }
    }
  }

  Future<void> _onCommonRecordMePressed(
      BuildContext context, List<Sample> samples, AppLocalizations l10n) async {
    // Show confirmation dialog
    final confirmed = await DialogService.showConfirmation(
      context,
      title: l10n.recordSampleConfirmTitle,
      message: l10n.recordSampleConfirmMessage,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
    );

    if (confirmed && context.mounted) {
      // Get current user ID from token
      final userService = getIt<UserService>();
      final currentLoggedInUserId =
          await userService.getCurrentUserIdWithFallback();

      // Build the sample data according to the API specification
      final sampleData = {
        "id": widget.patient.id,
        "isCollected": true,
        "isReceived": false,
        "samples": samples.map((sample) {
          // Get the current switch state for each sample
          final switchController = _getOrCreateController(sample);
          final currentUserId =
              switchController.value ? currentLoggedInUserId : null;

          return {
            "sampleType": sample.sampleType,
            "sampleColor": sample.sampleColor,
            "numberOfLabels": sample.numberOfLabels.toString(),
            "collectionTime": sample.collectionTime,
            "quality": sample.quality ?? "G",
            "collectorUserId": currentUserId,
            "receivedTime": sample.receivedTime,
            "receiverUserId": sample.receiverUserId,
            "sID": sample.sid,
            "subSID": sample.subSID,
          };
        }).toList(),
        "isManual": false,
      };

      // Send the update request
      context.read<SampleDetailsBloc>().add(
            UpdateSample(
              requestId: widget.patient.id,
              sampleData: sampleData,
            ),
          );
    }
  }
}
