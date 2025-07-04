import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/parameter_constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/patient_models.dart';
import '../bloc/patient_admissions_bloc.dart';
import '../bloc/patient_admissions_event.dart';
import '../bloc/patient_admissions_state.dart';
import '../widgets/patient_card.dart';

class PatientAdmissionsPage extends StatefulWidget {
  const PatientAdmissionsPage({super.key});

  @override
  State<PatientAdmissionsPage> createState() => _PatientAdmissionsPageState();
}

class _PatientAdmissionsPageState extends State<PatientAdmissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientAdmissionsBloc _bloc;
  final TextEditingController _patientIdController = TextEditingController();

  // Date range filtering
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  // Selected department
  String _selectedDepartmentCode = '';
  DepartmentParameter? _selectedDepartment;

  // Scroll controllers for infinite scroll
  final ScrollController _waitingScrollController = ScrollController();
  final ScrollController _sampleTakenScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc = getIt<PatientAdmissionsBloc>();
    _patientIdController.text = '';

    // Setup scroll listeners for infinite scroll
    _setupScrollListeners();

    // Load initial data
    _loadInitialData();
  }

  void _setupScrollListeners() {
    _waitingScrollController.addListener(() {
      if (_waitingScrollController.position.pixels >=
          _waitingScrollController.position.maxScrollExtent * 0.8) {
        _loadMoreWaitingForAdmission();
      }
    });

    _sampleTakenScrollController.addListener(() {
      if (_sampleTakenScrollController.position.pixels >=
          _sampleTakenScrollController.position.maxScrollExtent * 0.8) {
        _loadMoreSampleTaken();
      }
    });
  }

  void _loadInitialData() {
    _bloc.add(const LoadDepartments());
    _loadWaitingForAdmission(isRefresh: true);
    _loadSampleTaken(isRefresh: true);
  }

  void _loadWaitingForAdmission({bool isRefresh = false}) {
    final params = _buildQueryParams(page: isRefresh ? 1 : null);
    _bloc.add(LoadWaitingForAdmission(params: params, isRefresh: isRefresh));
  }

  void _loadSampleTaken({bool isRefresh = false}) {
    final params = _buildQueryParams(page: isRefresh ? 1 : null);
    _bloc.add(LoadSampleTaken(params: params, isRefresh: isRefresh));
  }

  void _loadMoreWaitingForAdmission() {
    final state = _bloc.state;
    if (!state.hasReachedMaxWaitingForAdmission &&
        !state.isLoadingMoreWaitingForAdmission) {
      final params =
          _buildQueryParams(page: state.currentWaitingForAdmissionPage + 1);
      _bloc.add(LoadMoreWaitingForAdmission(params: params));
    }
  }

  void _loadMoreSampleTaken() {
    final state = _bloc.state;
    if (!state.hasReachedMaxSampleTaken && !state.isLoadingMoreSampleTaken) {
      final params = _buildQueryParams(page: state.currentSampleTakenPage + 1);
      _bloc.add(LoadMoreSampleTaken(params: params));
    }
  }

  PatientVisitQueryParams _buildQueryParams({int? page}) {
    return PatientVisitQueryParams(
      size: ParameterConstants.defaultPageSize,
      page: page ?? 1,
      start: _formatDate(_fromDate),
      end: _formatDate(_toDate),
      search: _patientIdController.text.trim().isNotEmpty
          ? _patientIdController.text.trim()
          : null,
      serviceType:
          _selectedDepartmentCode.isNotEmpty ? _selectedDepartmentCode : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientIdController.dispose();
    _waitingScrollController.dispose();
    _sampleTakenScrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
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
              child: BlocBuilder<PatientAdmissionsBloc, PatientAdmissionsState>(
                builder: (context, state) {
                  return TabBar(
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
                                  colors: [
                                    Color(0xFFE53E3E),
                                    Color(0xFFD53F8C)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE53E3E)
                                        .withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${state.waitingForAdmissionPatients.length}',
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
                                  colors: [
                                    Color(0xFFE53E3E),
                                    Color(0xFFD53F8C)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE53E3E)
                                        .withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${state.sampleTakenPatients.length}',
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
                  );
                },
              ),
            ),

            // Filters with improved design
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Date Range Row
                  Row(
                    children: [
                      // From Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectFromDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFAFAFA),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Từ ngày',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        '${_fromDate.day.toString().padLeft(2, '0')}/${_fromDate.month.toString().padLeft(2, '0')}/${_fromDate.year}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // To Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectToDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFAFAFA),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đến ngày',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        '${_toDate.day.toString().padLeft(2, '0')}/${_toDate.month.toString().padLeft(2, '0')}/${_toDate.year}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Department Dropdown Row
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<PatientAdmissionsBloc,
                            PatientAdmissionsState>(
                          builder: (context, state) {
                            final allDepartments = [
                              DepartmentParameter(
                                id: 0,
                                parameterId: 0,
                                code: '',
                                sequence: 0,
                                languageCode: 'vi',
                                languageName: 'Tiếng Việt',
                                message: ParameterConstants
                                    .allDepartmentsDisplayName,
                                inUse: true,
                                isDefault: true,
                              ),
                              ...state.departments,
                            ];

                            return Container(
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
                                value: _selectedDepartmentCode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
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
                                items: allDepartments.map((dept) {
                                  return DropdownMenuItem<String>(
                                    value: dept.code,
                                    child: Text(
                                      dept.message,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedDepartmentCode = newValue ?? '';
                                    _selectedDepartment =
                                        allDepartments.firstWhere(
                                            (dept) => dept.code == newValue);
                                  });
                                  _refreshData();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Patient ID Search
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
                      onSubmitted: (value) => _refreshData(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _refreshData,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
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
                  ),
                ],
              ),
            ),

            // Patient Count
            BlocBuilder<PatientAdmissionsBloc, PatientAdmissionsState>(
              builder: (context, state) {
                final currentPatients = _tabController.index == 0
                    ? state.waitingForAdmissionPatients
                    : state.sampleTakenPatients;

                return Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.patientCount(currentPatients.length),
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
                );
              },
            ),

            const SizedBox(height: 8),

            // Patient List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWaitingForAdmissionList(),
                  _buildSampleTakenList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForAdmissionList() {
    return BlocBuilder<PatientAdmissionsBloc, PatientAdmissionsState>(
      builder: (context, state) {
        // Show initial loading with skeleton
        if (state.isLoadingWaitingForAdmission &&
            state.waitingForAdmissionPatients.isEmpty) {
          return _buildSkeletonLoading();
        }

        // Show error state with retry option
        if (state.errorMessage != null &&
            state.waitingForAdmissionPatients.isEmpty) {
          return _buildErrorState(
            errorMessage: state.errorMessage!,
            onRetry: () => _loadWaitingForAdmission(isRefresh: true),
          );
        }

        // Show empty state
        if (state.waitingForAdmissionPatients.isEmpty) {
          return _buildEmptyState(
            message: 'Không có bệnh nhân chờ nhập viện',
            icon: Icons.hourglass_empty,
          );
        }

        // Show list with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => _handleRefreshWaitingForAdmission(),
          color: const Color(0xFF1976D2),
          backgroundColor: Colors.white,
          strokeWidth: 2.5,
          child: ListView.separated(
            controller: _waitingScrollController,
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.waitingForAdmissionPatients.length +
                (state.isLoadingMoreWaitingForAdmission ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= state.waitingForAdmissionPatients.length) {
                return _buildPaginationLoading();
              }

              final patientVisit = state.waitingForAdmissionPatients[index];
              return PatientCard(
                key: ValueKey('waiting_${patientVisit.id}'),
                patient: patientVisit.toPatientInfo(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSampleTakenList() {
    return BlocBuilder<PatientAdmissionsBloc, PatientAdmissionsState>(
      builder: (context, state) {
        // Show initial loading with skeleton
        if (state.isLoadingSampleTaken && state.sampleTakenPatients.isEmpty) {
          return _buildSkeletonLoading();
        }

        // Show error state with retry option
        if (state.errorMessage != null && state.sampleTakenPatients.isEmpty) {
          return _buildErrorState(
            errorMessage: state.errorMessage!,
            onRetry: () => _loadSampleTaken(isRefresh: true),
          );
        }

        // Show empty state
        if (state.sampleTakenPatients.isEmpty) {
          return _buildEmptyState(
            message: 'Không có bệnh nhân đã lấy mẫu',
            icon: Icons.science,
          );
        }

        // Show list with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => _handleRefreshSampleTaken(),
          color: const Color(0xFF1976D2),
          backgroundColor: Colors.white,
          strokeWidth: 2.5,
          child: ListView.separated(
            controller: _sampleTakenScrollController,
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.sampleTakenPatients.length +
                (state.isLoadingMoreSampleTaken ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= state.sampleTakenPatients.length) {
                return _buildPaginationLoading();
              }

              final patientVisit = state.sampleTakenPatients[index];
              return PatientCard(
                key: ValueKey('sample_${patientVisit.id}'),
                patient: patientVisit.toPatientInfo(),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        // Ensure from date is not after to date
        if (_fromDate.isAfter(_toDate)) {
          _toDate = _fromDate;
        }
      });
      _refreshData();
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
        // Ensure to date is not before from date
        if (_toDate.isBefore(_fromDate)) {
          _fromDate = _toDate;
        }
      });
      _refreshData();
    }
  }

  void _refreshData() {
    _loadWaitingForAdmission(isRefresh: true);
    _loadSampleTaken(isRefresh: true);
  }

  // Enhanced refresh handlers for pull-to-refresh
  Future<void> _handleRefreshWaitingForAdmission() async {
    _loadWaitingForAdmission(isRefresh: true);
    // Wait for loading to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _handleRefreshSampleTaken() async {
    _loadSampleTaken(isRefresh: true);
    // Wait for loading to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Enhanced UI components for better UX
  Widget _buildSkeletonLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3, // Show 3 skeleton items
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildShimmerContainer(
                      height: 20, width: double.infinity),
                ),
                const SizedBox(width: 12),
                _buildShimmerContainer(height: 24, width: 80),
              ],
            ),
            const SizedBox(height: 8),
            _buildShimmerContainer(height: 16, width: 120),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildShimmerContainer(height: 12, width: 60),
                        const SizedBox(height: 8),
                        _buildShimmerContainer(height: 16, width: 80),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildShimmerContainer(height: 12, width: 60),
                        const SizedBox(height: 8),
                        _buildShimmerContainer(height: 16, width: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildShimmerContainer(
                        height: 40, width: double.infinity)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildShimmerContainer(
                        height: 40, width: double.infinity)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(
      {required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Thử lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Hãy thử thay đổi bộ lọc hoặc kéo xuống để làm mới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Đang tải thêm...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
