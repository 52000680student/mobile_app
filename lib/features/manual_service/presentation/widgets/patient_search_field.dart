import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/manual_service_models.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';
import '../bloc/manual_service_state.dart';

class PatientSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final Function(PatientSearchResult)? onPatientSelected;

  const PatientSearchField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.onPatientSelected,
  });

  @override
  State<PatientSearchField> createState() => _PatientSearchFieldState();
}

class _PatientSearchFieldState extends State<PatientSearchField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(List<PatientSearchResult> patients) {
    _removeOverlay();

    if (patients.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: patients.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      patient.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${patient.patientId}'),
                        Text('DOB: ${patient.dobName}'),
                        Text('Gender: ${patient.genderName}'),
                      ],
                    ),
                    onTap: () {
                      _selectPatient(patient);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectPatient(PatientSearchResult patient) {
    setState(() {
      widget.controller.text = patient.patientId;
    });

    // Notify bloc about selection
    context.read<ManualServiceBloc>().add(SelectPatientEvent(patient));

    // Notify parent widget
    widget.onPatientSelected?.call(patient);

    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ManualServiceBloc, ManualServiceState>(
      listener: (context, state) {
        if (state.patientSearchResults.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay(state.patientSearchResults);
        } else {
          _removeOverlay();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(l10n),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _layerLink,
            child: BlocBuilder<ManualServiceBloc, ManualServiceState>(
              builder: (context, state) {
                return TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchPatients,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: state.isSearchingPatients
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : widget.controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  widget.controller.clear();
                                  context
                                      .read<ManualServiceBloc>()
                                      .add(const ResetPatientSearchEvent());
                                  _removeOverlay();
                                },
                              )
                            : const Icon(Icons.search),
                    errorText: state.patientSearchError,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<ManualServiceBloc>().searchPatients(value);
                    } else {
                      context
                          .read<ManualServiceBloc>()
                          .add(const ResetPatientSearchEvent());
                      _removeOverlay();
                    }
                  },
                  onTap: () {
                    if (state.patientSearchResults.isNotEmpty) {
                      _showOverlay(state.patientSearchResults);
                    }
                  },
                  validator: widget.isRequired
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '${widget.label} is required';
                          }
                          return null;
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(AppLocalizations l10n) {
    return RichText(
      text: TextSpan(
        text: '${widget.label}:',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
        ),
        children: [
          if (widget.isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
