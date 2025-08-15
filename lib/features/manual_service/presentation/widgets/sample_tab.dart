import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/manual_service_models.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';

class SampleTab extends StatefulWidget {
  final List<SampleItem> samples;
  final Function(SampleItem) onSaveBarcode;
  final Function() onSaveAllBarcodes;

  const SampleTab({
    super.key,
    required this.samples,
    required this.onSaveBarcode,
    required this.onSaveAllBarcodes,
  });

  @override
  State<SampleTab> createState() => _SampleTabState();
}

class _SampleTabState extends State<SampleTab> {
  late ValueNotifier<bool> _switchController;

  @override
  void initState() {
    super.initState();
    _switchController = ValueNotifier<bool>(false);

    // Listen to switch changes and update BLoC state
    _switchController.addListener(() {
      if (mounted) {
        context.read<ManualServiceBloc>().add(
              ToggleSampleCollectionEvent(_switchController.value),
            );
      }
    });
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _showActionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy + button.size.height, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: AppConstants.getAllSamples,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_box_outlined,
                  size: 20, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(l10n.getAllSamples),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: AppConstants.receiveAllSamples,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_box_outlined,
                  size: 20, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(l10n.receiveAllSamples),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: AppConstants.saveAllBarcodes,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save_alt, size: 20, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(l10n.saveAllBarcodes),
            ],
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ).then((value) {
      if (value != null) {
        switch (value) {
          case AppConstants.getAllSamples:
            // Dispatch event to set collection time and user ID for all samples
            context.read<ManualServiceBloc>().add(
                  const SetCollectionTimeForAllSamplesEvent(),
                );
            _switchController.value = !_switchController.value;
            break;
          case AppConstants.receiveAllSamples:
            // Dispatch event to set receive time and user ID for all samples
            context.read<ManualServiceBloc>().add(
                  const SetReceiveTimeForAllSamplesEvent(),
                );
            // Mark samples as received in state
            context.read<ManualServiceBloc>().add(
                  const ToggleSampleReceiveEvent(true),
                );
            break;
          case AppConstants.saveAllBarcodes:
            widget.onSaveAllBarcodes();
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header with menu and switch
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Menu icon
                Builder(
                  builder: (context) => InkWell(
                    onTap: () => _showActionsMenu(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Icon section
                Icon(
                  Icons.checklist_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),

                const SizedBox(width: 12),

                // Text section
                Expanded(
                  child: Text(
                    l10n.selectAllSamples,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
        ),

        // Samples list
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom:
                  60, // Add bottom padding to ensure last item is fully visible
            ),
            itemCount: widget.samples.length,
            itemBuilder: (context, index) {
              final sample = widget.samples[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Barcode icon/image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Image.asset(
                              'assets/images/barcode.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Sample information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sample.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.sampleType}: ${sample.type}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.serialNumber}: ${sample.serialNumber}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.sidNumber}: ${sample.sid}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.timeCollected} ${sample.collectionTime?.toString().split(' ')[0] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.collectedBy} ${sample.collectionUserId?.toString() ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.receivedTime} ${sample.receiveTime?.toString().split(' ')[0] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.receiveUserId} ${sample.receiveUserId?.toString() ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator
                          ValueListenableBuilder<bool>(
                            valueListenable: _switchController,
                            builder: (context, isSelected, child) {
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : Colors.grey[300],
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Save barcode button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onSaveBarcode(sample);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                            side: BorderSide(color: theme.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.preview, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.previewBarcode),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Get the current value of the switch controller (isCollected state)
  bool get isCollected => _switchController.value;

  /// Get the current samples list
  List<SampleItem> get currentSamples => widget.samples;
}
