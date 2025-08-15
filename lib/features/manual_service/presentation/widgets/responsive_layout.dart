import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/user_service.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';
import '../bloc/manual_service_state.dart';
import '../../data/models/manual_service_models.dart';
import 'collapsible_section.dart';
import 'administrative_form.dart';
import 'service_selection.dart';
import '../../../../core/utils/app_logger.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ManualServiceBloc>(),
      child: _ResponsiveLayoutContent(),
    );
  }
}

class _ResponsiveLayoutContent extends StatefulWidget {
  @override
  State<_ResponsiveLayoutContent> createState() =>
      _ResponsiveLayoutContentState();
}

class _ResponsiveLayoutContentState extends State<_ResponsiveLayoutContent> {
  final GlobalKey _administrativeFormKey = GlobalKey();
  final GlobalKey _serviceSelectionKey = GlobalKey();
  bool _isLoading = false;

  void _onRefresh() async {
    setState(() => _isLoading = true);

    // Show confirmation dialog
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.refresh, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(l10n.confirmRefresh),
            ],
          ),
          content: Text(l10n.confirmRefreshMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      // Check if context is still mounted before calling BLoC events
      if (!mounted) return;

      // Clear BLoC state first
      context.read<ManualServiceBloc>().add(const ClearFormEvent());
      context.read<ManualServiceBloc>().add(const ResetPatientSearchEvent());

      // Reload fresh data from APIs
      context.read<ManualServiceBloc>().add(const LoadDepartmentsEvent());
      context.read<ManualServiceBloc>().add(const LoadServiceParametersEvent());
      context.read<ManualServiceBloc>().add(const LoadTestServicesEvent());
      context.read<ManualServiceBloc>().add(const LoadDoctorsEvent());
      context.read<ManualServiceBloc>().add(const LoadInitialPatientsEvent());

      // Clear administrative form local state
      try {
        final administrativeFormWidget = _administrativeFormKey.currentWidget;
        if (administrativeFormWidget != null) {
          final administrativeFormState = _administrativeFormKey.currentState;
          if (administrativeFormState != null &&
              administrativeFormState.mounted) {
            // Call the clearLocalStateOnly method on the AdministrativeForm
            (administrativeFormState as dynamic).clearLocalStateOnly();
          }
        }
      } catch (e) {
        AppLogger.info('Could not clear administrative form: $e');
      }

      // Clear service selection local state
      try {
        final serviceSelectionWidget = _serviceSelectionKey.currentWidget;
        if (serviceSelectionWidget != null) {
          final serviceSelectionState = _serviceSelectionKey.currentState;
          if (serviceSelectionState != null && serviceSelectionState.mounted) {
            // Call the clearLocalStateOnly method on the ServiceSelection
            (serviceSelectionState as dynamic).clearLocalStateOnly();
          }
        }
      } catch (e) {
        AppLogger.info('Could not clear service selection: $e');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.formsCleared),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _onSave() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      // Get the current state to access selected patient and test services
      final currentState = context.read<ManualServiceBloc>().state;

      // Validate that we have required data
      if (currentState.selectedPatient == null) {
        _showErrorMessage(l10n.pleaseSelectPatient);
        return;
      }

      // Validate administrative form required fields
      bool isFormValid = false;
      try {
        final administrativeFormWidget = _administrativeFormKey.currentWidget;
        if (administrativeFormWidget != null) {
          final administrativeFormState = _administrativeFormKey.currentState;
          if (administrativeFormState != null &&
              administrativeFormState.mounted) {
            isFormValid = (administrativeFormState as dynamic).validateForm();
          }
        }
      } catch (e) {
        AppLogger.info('Could not validate administrative form: $e');
      }

      if (!isFormValid) {
        _showErrorMessage(l10n.pleaseCompleteAllFields);
        return;
      }

      // Get form data from the administrative form
      Map<String, dynamic> formData = {};
      try {
        // Try to access the administrative form data
        final administrativeFormWidget = _administrativeFormKey.currentWidget;
        if (administrativeFormWidget != null) {
          final administrativeFormState = _administrativeFormKey.currentState;
          if (administrativeFormState != null &&
              administrativeFormState.mounted) {
            formData = (administrativeFormState as dynamic).getFormData();
          }
        }
      } catch (e) {
        // If we can't access the form, fall back to basic data
        l10n.administrativeFormNotAvailable;
      }

      // Merge with selected patient data and defaults
      formData = {
        'medicalId': formData['medicalId'] ?? "",
        'fullName': formData['fullName'] ?? currentState.selectedPatient!.name,
        'gender': formData['gender'] ?? currentState.selectedPatient!.gender,
        'phone': formData['phone'] ??
            currentState.selectedPatient!.phoneNumber ??
            "",
        'diagnosis': formData['diagnosis'] ?? "",
        'address': formData['address'] ?? currentState.selectedPatient!.address,
        'email': formData['email'] ?? "",
        'remark': formData['remark'] ?? "",
        'physicianId':
            formData['physicianId'] ?? 53661, // Now uses selected doctor ID
        'physicianName':
            formData['physicianName'] ?? "", // Now uses selected doctor name
        'departmentId': currentState.selectedDepartment?.id.toString() ?? "139",
        'serviceType': currentState.selectedServiceParameter?.code ?? "DV",
        'companyId': 1,
        'patientGroupType': "S",
        'profileId': 3,
      };
      final selectedPatient = currentState.selectedPatient!;

      // Get current user ID for collector if samples are collected
      final userService = getIt<UserService>();
      final currentUserId = await userService.getCurrentUserIdWithFallback();
      final currentUserIdInt = int.tryParse(currentUserId) ?? 1000004;

      // Get sample collection state from the switch controller in sample tab
      final isCollected = currentState.areSamplesCollected;
      // Get sample received state
      final isReReceived = currentState.areSamplesReceived;

      // Build the request according to Todo.txt specification
      final now = DateTime.now();
      final request = ManualServiceRequest(
        requestDate: now.toIso8601String(),
        requestid: "",
        alternateId: "",
        patientId: selectedPatient.patientId,
        medicalId: formData['medicalId'] ?? "",
        fullName: formData['fullName'] ?? selectedPatient.name,
        serviceType: formData['serviceType'] ?? "DV",
        dob: selectedPatient.dob,
        physicianId: formData['physicianId'] ?? 53661,
        physicianName: formData['physicianName'] ?? "",
        gender: formData['gender'] ?? selectedPatient.gender,
        departmentId: formData['departmentId'] ?? "139",
        phone: formData['phone'] ?? selectedPatient.phoneNumber ?? "",
        diagnosis: formData['diagnosis'] ?? "",
        address: formData['address'] ?? selectedPatient.address,
        resultTime: null,
        email: formData['email'] ?? "",
        remark: formData['remark'] ?? "",
        patient: selectedPatient.id,
        companyId: formData['companyId'] ?? 1,
        patientGroupType: formData['patientGroupType'] ?? "S",
        profileId: formData['profileId'] ?? 3,
        tests: currentState.selectedTestServices
            .map((testService) =>
                ManualServiceRequestTest.fromTestService(testService))
            .toList(),
        profiles: [], // Empty array as specified
        sidParam: SidParam.current(),
        individualValues:
            IndividualValues.fromPatientSearchResult(selectedPatient),
        samples: currentState.sampleItems
            .map((sampleItem) => ManualServiceRequestSample.fromSampleItem(
                sampleItem,
                isCollected,
                isReReceived,
                isCollected ? currentUserIdInt : null))
            .toList(),
        isCollected: isCollected,
        isReceived: isReReceived,
      );

      // Call the bloc to save the request
      context
          .read<ManualServiceBloc>()
          .add(SaveManualServiceRequestEvent(request));
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage(l10n.errorPreparingRequest(e.toString()));
    }
  }

  void _showErrorMessage(String message) {
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Get appointment date from the administrative form
  DateTime? _getAppointmentDate() {
    try {
      final administrativeFormWidget = _administrativeFormKey.currentWidget;
      if (administrativeFormWidget != null) {
        final administrativeFormState = _administrativeFormKey.currentState;
        if (administrativeFormState != null &&
            administrativeFormState.mounted) {
          final formData = (administrativeFormState as dynamic).getFormData();
          return formData['appointmentDate'] as DateTime?;
        }
      }
    } catch (e) {
      // If we can't access the form, return null
      AppLogger.info(
          'Could not access appointment date from administrative form: $e');
    }
    return null;
  }

  Widget _buildActionButtons(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Refresh Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _onRefresh,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(l10n.refresh),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Save Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _onSave,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<ManualServiceBloc, ManualServiceState>(
      listenWhen: (previous, current) {
        // Listen for save operation completion
        return previous.isSavingRequest != current.isSavingRequest ||
            previous.saveResponse != current.saveResponse ||
            previous.saveError != current.saveError;
      },
      listener: (context, state) {
        if (!state.isSavingRequest) {
          // Save operation completed
          setState(() => _isLoading = false);

          if (state.saveError != null) {
            // Show error message
            _showErrorMessage(state.saveError!);
          } else if (state.saveResponse != null) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l10n.requestSavedSuccessfully(state.saveResponse!.id)),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile layout (< 900px)
          if (constraints.maxWidth < 900) {
            return _buildMobileLayout(context, l10n, theme);
          }
          // Tablet/Desktop layout (>= 900px)
          else {
            return _buildTabletLayout(context, l10n, theme);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        // Single scrollable content containing both administrative form and service selection
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Administrative Information (Collapsible)
                CollapsibleSection(
                  title: l10n.administrativeInformation,
                  leadingIcon: Icons.description_outlined,
                  initiallyExpanded: true,
                  child: AdministrativeForm(key: _administrativeFormKey),
                ),

                const SizedBox(height: 24),

                // Service Selection with fixed height
                SizedBox(
                  height:
                      600, // Fixed height for service selection within scroll
                  child: ServiceSelection(
                    key: _serviceSelectionKey,
                    getAppointmentDate: _getAppointmentDate,
                  ),
                ),

                // Add some bottom padding to ensure content is accessible above action buttons
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Action Buttons
        _buildActionButtons(l10n, theme),
      ],
    );
  }

  Widget _buildTabletLayout(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Administrative Information - Scrollable
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: CollapsibleSection(
                    title: l10n.administrativeInformation,
                    leadingIcon: Icons.description_outlined,
                    initiallyExpanded: true,
                    child: AdministrativeForm(key: _administrativeFormKey),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Right side: Service Selection - Scrollable content
              Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                  child: ServiceSelection(
                    key: _serviceSelectionKey,
                    getAppointmentDate: _getAppointmentDate,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildActionButtons(l10n, theme),
        ),
      ],
    );
  }
}
