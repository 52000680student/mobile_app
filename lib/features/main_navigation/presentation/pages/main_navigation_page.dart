import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
  late AuthBloc _authBloc;

  final List<Widget> _pages = const [
    PatientAdmissionsPage(),
    ManualServicePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go(AppRoutes.login);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(l10n)),
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
                tooltip: l10n.logout,
              ),
            ],
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

  void _logout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _authBloc.add(const LogoutRequested());
              },
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}
