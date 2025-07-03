import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/patient_models.dart';
import '../widgets/patient_card.dart';

class PatientAdmissionsPage extends StatefulWidget {
  const PatientAdmissionsPage({super.key});

  @override
  State<PatientAdmissionsPage> createState() => _PatientAdmissionsPageState();
}

class _PatientAdmissionsPageState extends State<PatientAdmissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _patientIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedDepartment = 'Tất cả khoa';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _patientIdController.text = '0207250012';
    _selectedDepartment = 'Tất cả khoa';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  // Sample data for waiting for admission
  List<PatientInfo> get waitingPatients => [
        PatientInfo(
          id: '0207250012',
          name: 'CAO THI THU THẢO',
          birthDate: DateTime(2024, 6, 10),
          gender: 'Nữ',
          age: 1,
          object: 'DV',
          status: 'waitingForSample',
          statusColor: const Color(0xFF2196F3),
          samples: [
            SampleInfo(
              id: '0207250012_001',
              number: 1,
              type: 'venousBlood',
              timeCollected: '---',
              collectedBy: '---',
              quality: 'good',
              services: [
                SampleService(
                  code: 'XN001',
                  name: 'comprehensiveBloodTest',
                  subCode: '001',
                  description: 'Huyết học',
                ),
                SampleService(
                  code: 'XN002',
                  name: 'comprehensiveBloodTest',
                  subCode: '002',
                  description: 'Huyết học',
                ),
              ],
              isEnabled: true,
            ),
            SampleInfo(
              id: '0207250012_002',
              number: 2,
              type: 'urine',
              timeCollected: '---',
              collectedBy: '---',
              quality: 'good',
              services: [
                SampleService(
                  code: 'XN003',
                  name: 'generalUrineAnalysis',
                  subCode: '003',
                  description: 'Tổng phân tích nước tiểu',
                ),
              ],
              isEnabled: true,
            ),
            SampleInfo(
              id: '0207250012_003',
              number: 3,
              type: 'venousBlood',
              timeCollected: '---',
              collectedBy: '---',
              quality: 'good',
              services: [
                SampleService(
                  code: 'XN004',
                  name: 'comprehensiveBloodTest',
                  subCode: '004',
                  description: 'Sinh hóa',
                ),
              ],
              isEnabled: false,
            ),
          ],
        ),
        PatientInfo(
          id: '0207250011',
          name: 'TRẦN THI NGUYỆT',
          birthDate: DateTime(2002, 4, 4),
          gender: 'Nữ',
          age: 23,
          object: 'DV',
          status: 'waitingForSample',
          statusColor: const Color(0xFF2196F3),
        ),
      ];

  // Sample data for sample taken
  List<PatientInfo> get sampleTakenPatients => [
        PatientInfo(
          id: '0207250013',
          name: 'NGUYỄN VĂN AN',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Nam',
          age: 34,
          object: 'BHYT',
          status: 'sampleCollected',
          statusColor: const Color(0xFF4CAF50),
        ),
      ];

  List<PatientInfo> _getCurrentPatients() {
    return _tabController.index == 0 ? waitingPatients : sampleTakenPatients;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Add top padding for status bar
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Tabs with improved styling
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1976D2),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: Colors.grey.shade400,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.waitingForAdmission,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53E3E), Color(0xFFD53F8C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53E3E).withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${waitingPatients.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.sampleTaken,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53E3E), Color(0xFFD53F8C)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53E3E).withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${sampleTakenPatients.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters with improved design
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Date Picker with better styling
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFAFAFA),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x05000000),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Department Dropdown with better styling
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05000000),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1976D2), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            prefixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                          isExpanded: true,
                          items: [
                            'Tất cả khoa',
                            'Khoa Nội',
                            'Khoa Ngoại',
                            'Khoa Sản',
                            'Khoa Nhi',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDepartment = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Patient ID Search moved below filters with reduced spacing
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _patientIdController,
                    decoration: InputDecoration(
                      hintText: l10n.enterPatientId,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1976D2), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      prefixIcon: Icon(
                        Icons.person_search_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Patient Count with better typography
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.patientCount(_getCurrentPatients().length),
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.lastUpdated,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Patient List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientList(waitingPatients),
                _buildPatientList(sampleTakenPatients),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(List<PatientInfo> patients) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return PatientCard(patient: patient);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF374151),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
