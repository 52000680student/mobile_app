import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import '../../../../l10n/generated/app_localizations.dart';

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

  String _selectedGender = 'female';
  DateTime? _appointmentDate;
  DateTime? _dateOfBirth;
  String? _selectedServiceObject;
  String? _selectedDoctor;
  String? _selectedDepartment;

  final ValueNotifier<bool> _inpatientSwitch = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _emergencySwitch = ValueNotifier<bool>(false);

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
    _inpatientSwitch.dispose();
    _emergencySwitch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Patient ID, CCCD, SID
          _buildResponsiveRow([
            Expanded(
              child: _buildTextField(
                controller: _patientIdController,
                label: l10n.patientId,
                hint: l10n.patientIdHint,
                isRequired: true,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _cccdController,
                label: l10n.cccdNumber,
                hint: l10n.cccdHint,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _sidController,
                label: l10n.sidNumber,
                hint: l10n.sidNumber,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Second row: Full Name, Medical Code, Insurance Number
          _buildResponsiveRow([
            Expanded(
              child: _buildTextField(
                controller: _fullNameController,
                label: l10n.fullName,
                hint: l10n.fullNameHint,
                isRequired: true,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _medicalCodeController,
                label: l10n.medicalCode,
                hint: l10n.medicalCodeHint,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _insuranceNumberController,
                label: l10n.insuranceNumber,
                hint: l10n.insuranceNumberHint,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Third row: Gender, Appointment Date, Service Object
          _buildResponsiveRow([
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
              child: _buildDropdownField(
                label: l10n.serviceObject,
                value: _selectedServiceObject,
                items: [
                  l10n.chooseOption,
                  // Add more service objects as needed
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedServiceObject = value;
                  });
                },
                isRequired: true,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Fourth row: Date of Birth, Doctor, Department
          _buildResponsiveRow([
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
              child: _buildDropdownField(
                label: l10n.doctor,
                value: _selectedDoctor,
                items: [
                  l10n.chooseOption,
                  // Add more doctors as needed
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDoctor = value;
                  });
                },
                isRequired: true,
              ),
            ),
            Expanded(
              child: _buildDropdownField(
                label: l10n.department,
                value: _selectedDepartment,
                items: [
                  l10n.chooseOption,
                  // Add more departments as needed
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                isRequired: true,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Fifth row: Age, Phone, Email
          _buildResponsiveRow([
            Expanded(
              child: _buildTextField(
                controller: _ageController,
                label: l10n.age,
                hint: l10n.ageHint,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                label: l10n.phone,
                hint: l10n.phoneHint,
                keyboardType: TextInputType.phone,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: l10n.email,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Sixth row: Address, Notes, Diagnosis
          _buildResponsiveRow([
            Expanded(
              child: _buildTextField(
                controller: _addressController,
                label: l10n.address,
                hint: l10n.addressHint,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _notesController,
                label: l10n.notes,
                hint: l10n.notesHint,
                maxLines: 3,
              ),
            ),
            Expanded(
              child: _buildTextField(
                controller: _diagnosisController,
                label: l10n.diagnosis,
                hint: l10n.diagnosisHint,
                maxLines: 3,
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
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On mobile (< 600px), stack vertically
        if (constraints.maxWidth < 600) {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    ))
                .toList(),
          );
        }

        // On tablet/desktop, use row layout
        return Row(
          children: children
              .map((child) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: child,
                  ))
              .toList(),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
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
                value: 'male',
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
                value: 'female',
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
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
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
}
