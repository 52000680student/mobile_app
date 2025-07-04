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

class SampleDetailsModal extends StatefulWidget {
  final PatientInfo patient;

  const SampleDetailsModal({
    super.key,
    required this.patient,
  });

  static void show(BuildContext context, PatientInfo patient) {
    AppLogger.debug(
        'Opening sample details modal for patient ID: ${patient.id}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (ctx) => getIt<SampleDetailsBloc>()
            ..add(LoadSampleDetails(id: patient.id)),
          child: SampleDetailsModal(patient: patient),
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
    } else {
      // Update existing controller value based on current sample state
      final isCollected =
          sample.state >= 3 || (sample.collectionTime?.isNotEmpty == true);
      _switchControllers[sample.sampleId]!.value = isCollected;
    }
    return _switchControllers[sample.sampleId]!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SampleDetailsBloc, SampleDetailsState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
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
                        onPressed: () => Navigator.pop(context),
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
                                      LoadSampleDetails(id: widget.patient.id),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: state.samples.length,
                            itemBuilder: (context, index) {
                              final sample = state.samples[index];
                              return _buildSampleCard(
                                  sample, state.testDetails, l10n);
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
      child: AdvancedSwitch(
        controller: controller,
        activeColor: const Color(0xFF1976D2),
        inactiveColor: Colors.grey.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        width: 60.0,
        height: 32.0,
        enabled: false, // Read-only since it's based on API data
        thumb: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.value
                ? const Color(0xFF1976D2)
                : Colors.grey.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              controller.value ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        onChanged: (value) {
          //handle change
        },
      ),
    );
  }
}
