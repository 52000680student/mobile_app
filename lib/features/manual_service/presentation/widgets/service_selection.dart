import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/env/env_config.dart';
import '../../data/models/manual_service_models.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';
import '../bloc/manual_service_state.dart';
import 'services_tab.dart';
import 'sample_tab.dart';
import 'pdf_preview_screen.dart';

class ServiceSelection extends StatefulWidget {
  final DateTime? Function()? getAppointmentDate;

  const ServiceSelection({
    super.key,
    this.getAppointmentDate,
  });

  @override
  State<ServiceSelection> createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedServiceName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Clear all selected services and reset selection state
  void clearSelection() {
    setState(() {
      _selectedServiceName = null;
      _tabController.index = 0; // Reset to first tab
    });

    // Clear selected test services in the bloc
    context.read<ManualServiceBloc>().add(const ClearFormEvent());
  }

  /// Clear only local selection state without triggering BLoC events (for refresh functionality)
  void clearLocalStateOnly() {
    setState(() {
      _selectedServiceName = null;
      _tabController.index = 0; // Reset to first tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<ManualServiceBloc, ManualServiceState>(
      listenWhen: (previous, current) =>
          previous.barcodeSuccessMessage != current.barcodeSuccessMessage ||
          previous.barcodeError != current.barcodeError ||
          previous.pdfPreviewBytes != current.pdfPreviewBytes ||
          previous.pdfPreviewError != current.pdfPreviewError,
      listener: (context, state) {
        if (state.barcodeSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.barcodeSuccessMessage!)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state.barcodeError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.barcodeError!)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        // Handle PDF preview
        if (state.pdfPreviewBytes != null && state.pdfPreviewSample != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PdfPreviewScreen(
                pdfBytes: state.pdfPreviewBytes!,
                fileName:
                    'barcode_${state.pdfPreviewSample!.sid}_${DateTime.now().millisecondsSinceEpoch}.pdf',
                sampleName: state.pdfPreviewSample!.name,
              ),
            ),
          );

          // Clear the PDF preview data after navigation
          context.read<ManualServiceBloc>().add(const ClearPdfPreviewEvent());
        } else if (state.pdfPreviewError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.pdfPreviewError!)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: BlocBuilder<ManualServiceBloc, ManualServiceState>(
        builder: (context, state) {
          return Column(
            children: [
              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.services,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (state.selectedTestServices.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${state.selectedTestServices.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.biotech_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.sampleTab,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (state.sampleItems.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${state.sampleItems.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Service selection dropdown - only show for Services tab
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _tabController.index == 0 ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _tabController.index == 0 ? 1.0 : 0.0,
                      child: _tabController.index == 0
                          ? _buildServiceDropdown(l10n, theme, state)
                          : const SizedBox(height: 24),
                    ),
                  );
                },
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Services tab
                    ServicesTab(
                      testServices: state.selectedTestServices,
                      onDeleteService: (testService) {
                        context
                            .read<ManualServiceBloc>()
                            .add(RemoveTestServiceEvent(testService));
                      },
                    ),
                    // Sample tab
                    SampleTab(
                      samples: state.sampleItems,
                      onSaveBarcode: (sample) {
                        _showPdfPreview(sample);
                      },
                      onSaveAllBarcodes: () {
                        // For now, just show preview for the first sample
                        // TODO: Implement batch preview or selection dialog
                        if (state.sampleItems.isNotEmpty) {
                          _showPdfPreview(state.sampleItems.first);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServiceDropdown(
      AppLocalizations l10n, ThemeData theme, ManualServiceState state) {
    // Lazy load test services only when this dropdown is accessed
    if (state.availableTestServices.isEmpty &&
        !state.isLoadingTestServices &&
        state.testServicesError == null) {
      // Trigger loading only when dropdown is first accessed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ManualServiceBloc>().add(const LoadTestServicesEvent());
      });
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectService,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          state.isLoadingTestServices
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.loading),
                    ],
                  ),
                )
              : state.testServicesError != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.testServicesError!,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<ManualServiceBloc>()
                                  .add(const LoadTestServicesEvent());
                            },
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    )
                  : state.availableTestServices.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.grey.shade600, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                l10n.errorNoData,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : DropdownSearch<TestService>(
                          compareFn: (service1, service2) =>
                              service1.testCode == service2.testCode,
                          items: (filter, loadProps) {
                            // Always return current data, trigger load if needed
                            if (state.availableTestServices.isEmpty &&
                                !state.isLoadingTestServices &&
                                state.testServicesError == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context
                                    .read<ManualServiceBloc>()
                                    .add(const LoadTestServicesEvent());
                              });
                            }
                            return state.availableTestServices;
                          },
                          selectedItem: state.availableTestServices
                                  .where((service) =>
                                      service.testName == _selectedServiceName)
                                  .isNotEmpty
                              ? state.availableTestServices.firstWhere(
                                  (service) =>
                                      service.testName == _selectedServiceName)
                              : null,
                          onChanged: (testService) {
                            setState(() {
                              _selectedServiceName = testService?.testName;
                            });

                            if (testService != null) {
                              // Add the test service
                              context
                                  .read<ManualServiceBloc>()
                                  .add(AddTestServiceEvent(testService));

                              // Clear selection for next use
                              setState(() {
                                _selectedServiceName = null;
                              });
                            }
                          },
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              hintText: l10n.chooseOption,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: theme.primaryColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            itemBuilder:
                                (context, testService, isDisabled, isSelected) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor.withOpacity(0.1)
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testService.testName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? theme.primaryColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      'Code: ${testService.testCode} | Sample: ${testService.sampleTypeName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? theme.primaryColor
                                                .withOpacity(0.8)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            fit: FlexFit.loose,
                            constraints: const BoxConstraints(maxHeight: 300),
                            emptyBuilder: (context, searchEntry) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off,
                                        color: Colors.grey.shade400, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      searchEntry.isEmpty
                                          ? l10n.errorNoData
                                          : 'No results for "$searchEntry"',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          itemAsString: (testService) => testService.testName,
                        ),
        ],
      ),
    );
  }

  void _showPdfPreview(SampleItem sample) async {
    // Get appointment date from callback
    final appointmentDate = widget.getAppointmentDate?.call();

    // Trigger PDF preview event
    context.read<ManualServiceBloc>().add(
          ShowBarcodePdfPreviewEvent(
            sample: sample,
            baseUrl: EnvConfig.apiBaseUrl,
            appointmentDate: appointmentDate,
          ),
        );
  }
}
