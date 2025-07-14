import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../patient_admissions/presentation/pages/patient_admissions_page.dart';
import '../../../manual_service/presentation/pages/manual_service_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PatientAdmissionsPage(),
    ManualServicePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(l10n)),
        backgroundColor:
            Theme.of(context).primaryColor, // Use main project color
        foregroundColor: Colors.white,
        elevation: 0,
        // Removed logout action - now in settings page
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: const Color(0xFF6B7280),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_add_outlined),
              activeIcon: const Icon(Icons.person_add),
              label: l10n.patientAdmissions,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build_outlined),
              activeIcon: const Icon(Icons.build),
              label: l10n.manualServices,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return l10n.patientAdmissions;
      case 1:
        return l10n.manualServices;
      case 2:
        return l10n.settings;
      default:
        return l10n.appName;
    }
  }
}
