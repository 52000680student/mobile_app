import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/constants/patient_states.dart';
import '../../data/models/patient_models.dart';
import 'sample_details_modal.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/dialog_service.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/utils/user_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/take_all_samples_usecase.dart';

class PatientCard extends StatefulWidget {
  final PatientInfo patient;
  final bool isFromWaitingForAdmission;
  final VoidCallback? onRefresh;

  const PatientCard({
    super.key,
    required this.patient,
    this.isFromWaitingForAdmission = false,
    this.onRefresh,
  });

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Name and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.patient.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.patient.statusColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.patient.statusColor.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(widget.patient.status, l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Patient ID
              Text(
                'SID: ${widget.patient.sid}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Patient Details Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDetailRow(
                              l10n.birthDate,
                              '${widget.patient.birthDate.day.toString().padLeft(2, '0')}/${widget.patient.birthDate.month.toString().padLeft(2, '0')}/${widget.patient.birthDate.year}',
                              Icons.cake_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              l10n.gender,
                              widget.patient.gender,
                              widget.patient.gender == 'Nam'
                                  ? Icons.male
                                  : Icons.female,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDetailRow(
                              l10n.admissionDate,
                              '${widget.patient.requestDate.day.toString().padLeft(2, '0')}/${widget.patient.requestDate.month.toString().padLeft(2, '0')}/${widget.patient.requestDate.year}',
                              Icons.calendar_today_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              l10n.age,
                              '${widget.patient.age}',
                              Icons.access_time_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              l10n.patientType,
                              widget.patient.object,
                              Icons.card_membership_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => SampleDetailsModal.show(
                        context,
                        widget.patient,
                        isFromWaitingForAdmission:
                            widget.isFromWaitingForAdmission,
                        onRefresh: widget.onRefresh,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF1976D2), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: Color(0xFF1976D2),
                      ),
                      label: Text(
                        l10n.viewSample,
                        style: const TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_shouldShowTakeSampleButton(widget.patient.status))
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () =>
                                _onTakeSamplePressed(context, widget.patient),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                _shouldShowTakeSampleButton(
                                        widget.patient.status)
                                    ? Icons.medical_services_outlined
                                    : Icons.info_outline,
                                size: 18,
                              ),
                        label: Text(
                          _isLoading
                              ? l10n.processing
                              : (_shouldShowTakeSampleButton(
                                      widget.patient.status)
                                  ? l10n.takeSample
                                  : l10n.viewDetails),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String statusKey, AppLocalizations l10n) {
    // Use reflection-like approach to get localized text based on the status key
    switch (statusKey) {
      case 'patientStateDraft':
        return l10n.patientStateDraft;
      case 'patientStateSubmitted':
        return l10n.patientStateSubmitted;
      case 'patientStateCanceled':
        return l10n.patientStateCanceled;
      case 'patientStateCollected':
        return l10n.patientStateCollected;
      case 'patientStateDelivered':
        return l10n.patientStateDelivered;
      case 'patientStateReceived':
        return l10n.patientStateReceived;
      case 'patientStateOnHold':
        return l10n.patientStateOnHold;
      case 'patientStateInProcess':
        return l10n.patientStateInProcess;
      case 'patientStateCompleted':
        return l10n.patientStateCompleted;
      case 'patientStateConfirmed':
        return l10n.patientStateConfirmed;
      case 'patientStateValidated':
        return l10n.patientStateValidated;
      case 'patientStateReleased':
        return l10n.patientStateReleased;
      case 'patientStateSigned':
        return l10n.patientStateSigned;
      case 'patientStateApproved':
        return l10n.patientStateApproved;
      // Legacy support for old status keys
      case 'waitingForSample':
        return l10n.waitingForSample;
      case 'sampleCollected':
        return l10n.sampleCollected;
      default:
        return statusKey;
    }
  }

  bool _shouldShowTakeSampleButton(String statusKey) {
    // Show "Take Sample" button for states that are waiting for sample collection
    switch (statusKey) {
      case 'patientStateDraft':
      case 'patientStateSubmitted':
      case 'patientStateConfirmed':
      case 'waitingForSample': // Legacy support
        return true;
      default:
        return false;
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onTakeSamplePressed(
      BuildContext context, PatientInfo patient) async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await DialogService.showConfirmation(
      context,
      title: l10n.takeSampleConfirmTitle,
      message: l10n.takeSampleConfirmMessage,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID from token
      final userService = getIt<UserService>();
      final userId = await userService.getCurrentUserIdWithFallback();

      // Get the use case and call the API
      final takeAllSamplesUseCase = getIt<TakeAllSamplesUseCase>();
      final result = await takeAllSamplesUseCase(patient.id, userId);

      // Check context is still mounted after async operation
      if (!context.mounted) {
        return;
      }

      result.fold(
        (failure) {
          // Show error message
          ToastService.showError(context, failure.message);
        },
        (success) {
          // Show success message
          ToastService.showSuccess(context, l10n.takeSampleSuccess);
          // Call refresh callback
          widget.onRefresh?.call();
        },
      );
    } catch (e, stackTrace) {
      // Handle any unexpected errors
      AppLogger.error('Exception in take sample: $e', stackTrace);
      if (context.mounted) {
        ToastService.showError(context, l10n.takeSampleError);
      }
    } finally {
      // Clear loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
