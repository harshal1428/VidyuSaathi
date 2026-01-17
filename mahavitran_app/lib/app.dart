import 'package:flutter/material.dart';
import 'presentation/screens/Officer/dashboards/je_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ae_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/dyee_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ee_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/se_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ce_dashboard_screen.dart';

/// Mahavitran VidyuSaathi Main Application
/// Multi-role officer dashboard system with role-based routing
class MahavitranApp extends StatefulWidget {
  // Optional: userRole can be passed from login screen
  final String? initialUserRole;
  final String? initialUserName;

  const MahavitranApp({
    Key? key,
    this.initialUserRole,
    this.initialUserName,
  }) : super(key: key);

  @override
  State<MahavitranApp> createState() => _MahavitranAppState();
}

class _MahavitranAppState extends State<MahavitranApp> {
  // Default demo values - in real app, these come from login/auth system
  late String userRole;
  late String userName;

  @override
  void initState() {
    super.initState();
    // Use provided values or defaults for demo
    userRole = widget.initialUserRole ?? 'EE';
    userName = widget.initialUserName ?? 'Demo User';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahavitran VidyuSaathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          primary: Colors.blue.shade800,
          secondary: Colors.orange,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          elevation: 2,
          surfaceTintColor: Colors.blue.shade800,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      // Route to appropriate dashboard based on user role
      home: _getDashboardForRole(userRole, userName),
    );
  }

  /// Get dashboard widget based on user role
  Widget _getDashboardForRole(String role, String name) {
    switch (role.toUpperCase()) {
      case 'JE':
        return JEDashboardScreen(
          userRole: role,
          userName: name,
        );
      case 'AE':
        return AEDashboardScreen(
          userRole: role,
          userName: name,
        );
      case 'DYEE':
        return DyEEDashboardScreen(
          userRole: role,
          userName: name,
        );
      case 'EE':
        return EEDashboardScreen(
          userRole: role,
          userName: name,
        );
      case 'SE':
        return SEDashboardScreen(
          userRole: role,
          userName: name,
        );
      case 'CE':
        return CEDashboardScreen(
          userRole: role,
          userName: name,
        );
      default:
        // Default to JE dashboard if role not recognized
        return JEDashboardScreen(
          userRole: 'JE',
          userName: name,
        );
    }
  }
}
