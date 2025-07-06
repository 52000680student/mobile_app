import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'services_tab.dart';
import 'sample_tab.dart';

class ServiceSelection extends StatefulWidget {
  const ServiceSelection({super.key});

  @override
  State<ServiceSelection> createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedService;

  // Sample service data
  final List<ServiceItem> _services = [
    ServiceItem(
      name: 'Định lượng Triglycerid',
      code: 'Mã DV: 4857',
      status: 'Mẫu [Citrat 3.2%]',
      statusColor: Colors.orange,
    ),
    ServiceItem(
      name: 'Xét nghiệm SARS-CoV-2 Ag Test nhanh',
      code: 'Mã DV: xuan1',
      status: 'Mẫu [Chất cây mẫu]',
      statusColor: Colors.blue,
    ),
  ];

  // Sample data for the sample tab
  final List<SampleItem> _samples = [
    SampleItem(
      name: 'Định lượng Triglycerid',
      type: 'Citrat 3.2%',
      serialNumber: '3',
      sid: 'Auto',
      collectionTime: DateTime.now().subtract(const Duration(hours: 2)),
      collectionUserId: 1001,
    ),
    SampleItem(
      name: 'Xét nghiệm SARS-CoV-2 Ag Test nhanh',
      type: 'Chất cây mẫu',
      serialNumber: '3',
      sid: 'Auto',
      collectionTime: DateTime.now().subtract(const Duration(hours: 1)),
      collectionUserId: 1002,
    ),
    SampleItem(
      name: 'Xét nghiệm Covid',
      type: 'Nhập tay',
      serialNumber: '3',
      sid: 'Auto',
      collectionTime: DateTime.now().subtract(const Duration(hours: 1)),
      collectionUserId: 1002,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.services),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '2',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _tabController.index == 0
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.sampleTab),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '2',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _tabController.index == 1
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

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
                    ? _buildDropdown(l10n, theme)
                    : const SizedBox(height: 24),
              ),
            );
          },
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Services tab
              ServicesTab(
                services: _services,
                onDeleteService: (service) {
                  // Handle delete service
                },
              ),
              // Sample tab
              SampleTab(
                samples: _samples,
                onSaveBarcode: (sample) {
                  // Handle save barcode
                },
                onSaveAllBarcodes: () {
                  // Handle save all barcodes
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(l10n, theme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.selectServiceLabel}:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedService,
                hint: Text(l10n.selectService),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  'Định lượng Triglycerid',
                  'Xét nghiệm SARS-CoV-2 Ag Test nhanh',
                  'Xét nghiệm máu tổng quát',
                  'Tổng phân tích nước tiểu',
                ].map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
