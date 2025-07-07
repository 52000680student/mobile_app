import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/manual_service_bloc.dart';
import 'collapsible_section.dart';
import 'administrative_form.dart';
import 'service_selection.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
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
      // TODO: Clear all forms - implement form clearing logic
      // _administrativeFormKey.currentState?.clearForm();
      // _serviceSelectionKey.currentState?.clearSelection();

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

    // TODO: Validate forms first - implement form validation logic
    // final bool isAdministrativeFormValid =
    //     _administrativeFormKey.currentState?.validateForm() ?? false;

    // For now, assume form is valid - implement validation logic later
    // if (!isAdministrativeFormValid) {
    //   setState(() => _isLoading = false);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Row(
    //         children: [
    //           const Icon(Icons.error, color: Colors.white),
    //           const SizedBox(width: 8),
    //           Text(AppLocalizations.of(context)!.pleaseCompleteAllFields),
    //         ],
    //       ),
    //       backgroundColor: Colors.red,
    //       duration: const Duration(seconds: 3),
    //     ),
    //   );
    //   return;
    // }

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual API call here
    // final result = await apiService.saveManualService(data);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.dataSavedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

    return BlocProvider(
      create: (context) => getIt<ManualServiceBloc>(),
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
                  child: ServiceSelection(key: _serviceSelectionKey),
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
                  child: ServiceSelection(key: _serviceSelectionKey),
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
