import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/debouncer.dart';
import '../../data/models/manual_service_models.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';
import '../bloc/manual_service_state.dart';

class AdministrativeForm extends StatefulWidget {
  const AdministrativeForm({super.key});

  @override
  State<AdministrativeForm> createState() => _AdministrativeFormState();
}

class _AdministrativeFormState extends State<AdministrativeForm> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _cccdController = TextEditingController();
  final _sidController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _medicalCodeController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _diagnosisController = TextEditingController();

  // Add focus nodes for better focus management
  final _cccdFocusNode = FocusNode();
  final _sidFocusNode = FocusNode();
  final _fullNameFocusNode = FocusNode();
  final _medicalCodeFocusNode = FocusNode();
  final _insuranceNumberFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();
  final _diagnosisFocusNode = FocusNode();

  String _selectedGender = 'F';
  DateTime? _appointmentDate;
  DateTime? _dateOfBirth;
  String? _selectedServiceObject;
  String? _selectedDoctor;
  String? _selectedDepartment;

  final ValueNotifier<bool> _inpatientSwitch = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _emergencySwitch = ValueNotifier<bool>(false);

  // Cache for responsive layout calculations
  bool? _isMobileLayout;
  double? _lastConstraintWidth;

  // Add debouncer for text input
  late final Debouncer _inputDebouncer;

  @override
  void initState() {
    super.initState();
    _inputDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _cccdController.dispose();
    _sidController.dispose();
    _fullNameController.dispose();
    _medicalCodeController.dispose();
    _insuranceNumberController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _diagnosisController.dispose();

    // Dispose focus nodes
    _cccdFocusNode.dispose();
    _sidFocusNode.dispose();
    _fullNameFocusNode.dispose();
    _medicalCodeFocusNode.dispose();
    _insuranceNumberFocusNode.dispose();
    _ageFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _notesFocusNode.dispose();
    _diagnosisFocusNode.dispose();

    _inpatientSwitch.dispose();
    _emergencySwitch.dispose();
    _inputDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Separate the listener and builder for better performance
    return BlocListener<ManualServiceBloc, ManualServiceState>(
      listenWhen: (previous, current) {
        // Only listen when selectedPatient actually changes
        return previous.selectedPatient != current.selectedPatient;
      },
      listener: (context, state) {
        if (state.selectedPatient != null) {
          // Auto-fill form when patient is selected
          _autoFillPatientData(state.selectedPatient!);
        } else {
          // Clear local form when patient is deselected/cleared
          // Use a small delay to ensure the clearing happens after any ongoing state updates
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _clearLocalFormState();
            }
          });
        }
      },
      child: BlocBuilder<ManualServiceBloc, ManualServiceState>(
        buildWhen: (previous, current) {
          // Only rebuild when relevant fields change
          return previous.selectedPatient != current.selectedPatient ||
              previous.serviceParameters != current.serviceParameters ||
              previous.departments != current.departments ||
              previous.isLoadingServiceParameters !=
                  current.isLoadingServiceParameters ||
              previous.isLoadingDepartments != current.isLoadingDepartments ||
              previous.patientSearchResults != current.patientSearchResults ||
              previous.isSearchingPatients != current.isSearchingPatients ||
              previous.patientSearchError != current.patientSearchError ||
              previous.selectedDepartment != current.selectedDepartment ||
              previous.selectedServiceParameter !=
                  current.selectedServiceParameter ||
              previous.selectedTestServices != current.selectedTestServices;
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Patient ID, CCCD, SID
                _buildOptimizedRow([
                  Expanded(
                    child: _buildPatientDropdown(l10n, state),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _cccdController,
                      label: l10n.cccdNumber,
                      hint: l10n.cccdHint,
                      enabled: state.selectedPatient == null,
                      focusNode: _cccdFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _sidController,
                      label: l10n.sidNumber,
                      hint: l10n.sidNumber,
                      focusNode: _sidFocusNode,
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // Second row: Full Name, Medical Code, Insurance Number
                _buildOptimizedRow([
                  Expanded(
                    child: _buildTextField(
                      controller: _fullNameController,
                      label: l10n.fullName,
                      hint: l10n.fullNameHint,
                      isRequired: true,
                      focusNode: _fullNameFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _medicalCodeController,
                      label: l10n.medicalCode,
                      hint: l10n.medicalCodeHint,
                      focusNode: _medicalCodeFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _insuranceNumberController,
                      label: l10n.insuranceNumber,
                      hint: l10n.insuranceNumberHint,
                      focusNode: _insuranceNumberFocusNode,
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // Third row: Gender, Appointment Date, Service Object
                _buildOptimizedRow([
                  Expanded(
                    child: _buildGenderSelection(l10n),
                  ),
                  Expanded(
                    child: _buildDateField(
                      label: l10n.appointmentDate,
                      selectedDate: _appointmentDate,
                      onDateSelected: (date) {
                        setState(() {
                          _appointmentDate = date;
                        });
                      },
                      isRequired: true,
                    ),
                  ),
                  Expanded(
                    child: _buildServiceObjectDropdown(l10n, state),
                  ),
                ]),

                const SizedBox(height: 16),

                // Fourth row: Date of Birth, Doctor, Department
                _buildOptimizedRow([
                  Expanded(
                    child: _buildDateField(
                      label: l10n.dateOfBirth,
                      selectedDate: _dateOfBirth,
                      onDateSelected: (date) {
                        setState(() {
                          _dateOfBirth = date;
                        });
                      },
                      isRequired: true,
                    ),
                  ),
                  Expanded(
                    child: _buildDoctorDropdown(l10n, state),
                  ),
                  Expanded(
                    child: _buildDepartmentDropdown(l10n, state),
                  ),
                ]),

                const SizedBox(height: 16),

                // Fifth row: Age, Phone, Email
                _buildOptimizedRow([
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: l10n.age,
                      hint: l10n.ageHint,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      focusNode: _ageFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: l10n.phone,
                      hint: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                      focusNode: _phoneFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: l10n.email,
                      hint: l10n.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocusNode,
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // Sixth row: Address, Notes, Diagnosis
                _buildOptimizedRow([
                  Expanded(
                    child: _buildTextField(
                      controller: _addressController,
                      label: l10n.address,
                      hint: l10n.addressHint,
                      focusNode: _addressFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _notesController,
                      label: l10n.notes,
                      hint: l10n.notesHint,
                      maxLines: 3,
                      focusNode: _notesFocusNode,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _diagnosisController,
                      label: l10n.diagnosis,
                      hint: l10n.diagnosisHint,
                      maxLines: 3,
                      focusNode: _diagnosisFocusNode,
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Switches row
                Row(
                  children: [
                    Expanded(
                      child: _buildSwitchField(
                        label: l10n.inpatient,
                        valueNotifier: _inpatientSwitch,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSwitchField(
                        label: l10n.emergency,
                        valueNotifier: _emergencySwitch,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Auto-fill form fields when a patient is selected
  void _autoFillPatientData(PatientSearchResult patient) {
    setState(() {
      _fullNameController.text = patient.name;
      _selectedGender = patient.gender;
      _addressController.text = patient.address;
      _appointmentDate =
          DateTime.now(); // Set to current date as per requirements
      _cccdController.clear(); // Clear but disable as per requirements

      // Parse and set date of birth
      final dob = patient.getParsedDob();
      if (dob != null) {
        _dateOfBirth = dob;
        // Calculate and set age
        final age = patient.calculateAge();
        _ageController.text = age.toString();
      }

      // Set phone if available
      if (patient.phoneNumber != null && patient.phoneNumber!.isNotEmpty) {
        _phoneController.text = patient.phoneNumber!;
      }
    });
  }

  /// Optimized patient dropdown with search functionality
  Widget _buildPatientDropdown(
      AppLocalizations l10n, ManualServiceState state) {
    // Add debugging for dropdown state
    print(
        'PatientDropdown: Building with ${state.patientSearchResults.length} results');
    print(
        'PatientDropdown: isSearching=${state.isSearchingPatients}, error=${state.patientSearchError}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(l10n.patientId, true),
        const SizedBox(height: 8),
        DropdownSearch<PatientSearchResult>(
          compareFn: (patient1, patient2) =>
              patient1.patientId == patient2.patientId,
          items: (filter, loadProps) {
            print(
                'DropdownSearch items callback: filter="$filter", results=${state.patientSearchResults.length}');

            // Always trigger search for any filter change (including empty, space, or any text)
            final searchQuery =
                filter.trim(); // Trim spaces but allow empty search
            print('DropdownSearch: Triggering search for "$searchQuery"');

            // Use debouncer to avoid excessive API calls while typing
            _inputDebouncer.call(() {
              context
                  .read<ManualServiceBloc>()
                  .add(SearchPatientsEvent(searchQuery));
            });

            return state.patientSearchResults;
          },
          selectedItem: state.selectedPatient,
          onChanged: (PatientSearchResult? patient) {
            print('DropdownSearch: Patient selected: ${patient?.name}');
            if (patient != null) {
              setState(() {
                _patientIdController.text = patient.patientId;
              });
              context
                  .read<ManualServiceBloc>()
                  .add(SelectPatientEvent(patient));
            }
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: l10n.searchPatients,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            baseStyle: const TextStyle(fontSize: 14),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: l10n.searchPatients,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            itemBuilder: (context, patient, isDisabled, isSelected) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient.patientId} - ${patient.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    Text(
                      '${patient.genderName} | ${patient.dobName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.8)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 300),
            loadingBuilder: (context, searchEntry) => Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(state.isSearchingPatients ? l10n.loading : l10n.loading),
                ],
              ),
            ),
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
                      state.patientSearchError != null
                          ? state.patientSearchError!
                          : (searchEntry.trim().isEmpty
                              ? 'Type to search for patients'
                              : '${l10n.errorNoData} "$searchEntry"'),
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          itemAsString: (PatientSearchResult patient) =>
              '${patient.patientId} - ${patient.name}',
        ),
      ],
    );
  }

  /// Optimized service object dropdown
  Widget _buildServiceObjectDropdown(
      AppLocalizations l10n, ManualServiceState state) {
    final serviceOptions = [
      l10n.chooseOption,
      ...state.serviceParameters.map((param) => param.message),
    ];

    return _buildDropdownField(
      l10n: l10n,
      label: l10n.serviceObject,
      value: _selectedServiceObject,
      items: serviceOptions,
      onChanged: (value) {
        setState(() {
          _selectedServiceObject = value;
        });

        if (value != null && value != l10n.chooseOption) {
          final selectedParam = state.serviceParameters
              .firstWhere((param) => param.message == value);
          context
              .read<ManualServiceBloc>()
              .add(SelectServiceParameterEvent(selectedParam));
        }
      },
      isRequired: true,
      isLoading: state.isLoadingServiceParameters,
    );
  }

  /// Optimized department dropdown
  Widget _buildDepartmentDropdown(
      AppLocalizations l10n, ManualServiceState state) {
    final departmentOptions = [
      l10n.chooseOption,
      ...state.departments.map((dept) => dept.name),
    ];

    return _buildDropdownField(
      l10n: l10n,
      label: l10n.department,
      value: _selectedDepartment,
      items: departmentOptions,
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
        });

        if (value != null && value != l10n.chooseOption) {
          final selectedDept =
              state.departments.firstWhere((dept) => dept.name == value);
          context
              .read<ManualServiceBloc>()
              .add(SelectDepartmentEvent(selectedDept));
        }
      },
      isRequired: true,
      isLoading: state.isLoadingDepartments,
    );
  }

  /// Optimized responsive row with caching
  Widget _buildOptimizedRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cache layout calculation to avoid repeated computations
        // Add tolerance to prevent constant recalculation during keyboard animations
        final currentWidth = constraints.maxWidth;
        final tolerance = 10.0; // 10px tolerance

        if (_lastConstraintWidth == null ||
            (currentWidth - _lastConstraintWidth!).abs() > tolerance) {
          _lastConstraintWidth = currentWidth;
          _isMobileLayout = currentWidth < 600;
        }

        // Use cached layout
        if (_isMobileLayout!) {
          // In mobile layout, remove Expanded wrapper and add proper spacing
          return Column(
            children: children.asMap().entries.map((entry) {
              final child = entry.value;
              // Extract the actual widget from Expanded wrapper if it exists
              Widget actualChild = child;
              if (child is Expanded) {
                actualChild = child.child;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: actualChild,
              );
            }).toList(),
          );
        }

        // Desktop layout - use Row with Flexible instead of Expanded to prevent overflow
        return Row(
          children: children.asMap().entries.map((entry) {
            final child = entry.value;
            Widget actualChild = child;
            if (child is Expanded) {
              actualChild = Flexible(
                flex: child.flex,
                child: child.child,
              );
            }

            // Don't add right padding to the last item
            final isLast = entry.key == children.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 16),
              child: actualChild,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int? maxLines,
    bool isRequired = false,
    bool enabled = true,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          enabled: enabled,
          // Optimize text input handling
          enableInteractiveSelection: true,
          autocorrect: false,
          enableSuggestions: keyboardType != TextInputType.emailAddress &&
              keyboardType != TextInputType.phone &&
              keyboardType != TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            fillColor: enabled ? null : Colors.grey.shade100,
            filled: !enabled,
            // Remove dense to improve touch targets
            isDense: false,
          ),
          // Add input formatters for better performance
          onTapOutside: (event) {
            // Explicitly unfocus this field when tapping outside
            focusNode?.unfocus();
            // Also ensure no other fields are focused
            FocusScope.of(context).unfocus();
          },
          // Prevent auto focus restoration during rebuilds
          onTap: () {
            // Only request focus if user explicitly taps the field
            // This prevents auto focus during widget rebuilds
            if (focusNode != null && !focusNode.hasFocus) {
              FocusScope.of(context).requestFocus(focusNode);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(l10n.gender, true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(l10n.male),
                value: 'M',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text(l10n.female),
                value: 'F',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                        : '07/05/2025',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required AppLocalizations l10n,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        const SizedBox(height: 8),
        isLoading
            ? Container(
                height: 58,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Flexible(child: Text(l10n.loading)),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    isExpanded: true, // This helps prevent overflow
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: SizedBox(
                          width: constraints.maxWidth -
                              50, // Account for padding and icon
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
        text: '$label:',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
        ),
        children: [
          if (isRequired)
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

  Widget _buildSwitchField({
    required String label,
    required ValueNotifier<bool> valueNotifier,
  }) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<bool>(
          valueListenable: valueNotifier,
          builder: (context, value, child) {
            return AdvancedSwitch(
              controller: valueNotifier,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey.shade300,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              width: 50,
              height: 30,
              enabled: true,
              disabledOpacity: 0.5,
            );
          },
        ),
      ],
    );
  }

  /// Optimized doctor dropdown with search functionality
  Widget _buildDoctorDropdown(AppLocalizations l10n, ManualServiceState state) {
    final doctorOptions = <String>[
      // Empty list - will be populated when doctor API is implemented
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(l10n.doctor, true),
        const SizedBox(height: 8),
        doctorOptions.isEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Doctor data not available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : DropdownSearch<String>(
                items: (filter, loadProps) {
                  // Only provide search functionality when data is available
                  if (doctorOptions.isEmpty) {
                    return <String>[];
                  }

                  // Filter doctors based on search input
                  if (filter.isEmpty) {
                    return doctorOptions;
                  }
                  return doctorOptions
                      .where((doctor) =>
                          doctor.toLowerCase().contains(filter.toLowerCase()))
                      .toList();
                },
                selectedItem: _selectedDoctor,
                onChanged: (String? doctor) {
                  setState(() {
                    _selectedDoctor = doctor;
                  });
                },
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    hintText: l10n.chooseOption,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: doctorOptions.isNotEmpty,
                  searchFieldProps: const TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bác sĩ...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                  itemBuilder: (context, doctor, isDisabled, isSelected) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                      ),
                      child: Text(
                        doctor,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
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
                                ? 'No doctors found'
                                : 'No results for "$searchEntry"',
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  /// Clear only local UI state without triggering bloc events
  void _clearLocalFormState() {
    setState(() {
      // Clear all text controllers
      _patientIdController.clear();
      _cccdController.clear();
      _sidController.clear();
      _fullNameController.clear();
      _medicalCodeController.clear();
      _insuranceNumberController.clear();
      _ageController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
      _notesController.clear();
      _diagnosisController.clear();

      // Reset dropdown selections
      _selectedGender = 'F';
      _appointmentDate = null;
      _dateOfBirth = null;
      _selectedServiceObject = null;
      _selectedDoctor = null;
      _selectedDepartment = null;

      // Reset switches
      _inpatientSwitch.value = false;
      _emergencySwitch.value = false;
    });

    // Clear focus from all input fields
    _cccdFocusNode.unfocus();
    _sidFocusNode.unfocus();
    _fullNameFocusNode.unfocus();
    _medicalCodeFocusNode.unfocus();
    _insuranceNumberFocusNode.unfocus();
    _ageFocusNode.unfocus();
    _phoneFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _addressFocusNode.unfocus();
    _notesFocusNode.unfocus();
    _diagnosisFocusNode.unfocus();
  }

  /// Clear all form data and reset to initial state with bloc events
  void clearForm() {
    // Clear local UI state first
    _clearLocalFormState();

    // Then trigger bloc events
    context.read<ManualServiceBloc>().add(const ClearFormEvent());
    context.read<ManualServiceBloc>().add(const ResetPatientSearchEvent());
  }
}
