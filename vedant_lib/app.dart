import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Officer Dashboards
import 'presentation/screens/Officer/dashboards/fe_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/je_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ae_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/dyee_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ee_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/se_dashboard_screen.dart';
import 'presentation/screens/Officer/dashboards/ce_dashboard_screen.dart';

// Admin
import 'presentation/screens/admin/home_screen.dart';
import 'presentation/provider/admin/theme_provider.dart';
import 'presentation/provider/admin/analytics_provider.dart';
import 'presentation/theme/app_theme.dart';

// Auth Screens
import 'presentation/screens/auth/home_page.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/registration_screen.dart';
import 'presentation/screens/auth/seeder_screen.dart';

// Citizen Screens
import 'presentation/screens/Citizen/citizen_dashboard.dart';
import 'presentation/screens/Citizen/citizen_profile_screen.dart';
import 'presentation/screens/Citizen/my_reports_screen.dart';
import 'presentation/screens/Citizen/report_issue_screen.dart';

// Services
import 'data/services/auth/auth_service.dart';

// Constants
import 'core/constants/app_constants.dart';

/// Mahavitran VidyuSaathi Main Application
/// Unified app with auth flow, citizen screens, officer dashboards, and admin panel
class MahavitranApp extends StatelessWidget {
  /// Start mode determines initial screen:
  /// - 'auth': Start with login/home page (default for production)
  /// - 'admin': Jump directly to admin dashboard (for testing)
  /// - 'citizen': Jump directly to citizen dashboard (for testing)
  /// - 'officer': Jump to officer dashboard based on role
  final String startMode;
  final String? initialUserRole;
  final String? initialUserName;

  const MahavitranApp({
    Key? key,
    this.startMode = 'admin',
    this.initialUserRole,
    this.initialUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service - available throughout the app
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Admin providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Mahavitran VidyuSaathi',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // Start based on mode
            initialRoute: _getInitialRoute(),
            routes: _buildRoutes(),
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }

  String _getInitialRoute() {
    switch (startMode.toLowerCase()) {
      case 'admin':
        return AppConstants.routeAdminDashboard;
      case 'citizen':
        return AppConstants.routeCitizenDashboard;
      case 'officer':
        return AppConstants.routeOfficerDashboard;
      default:
        return AppConstants.routeHome;
    }
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
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
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      // Auth Routes
      AppConstants.routeHome: (context) => const HomePage(),
      AppConstants.routeLogin: (context) => const LoginScreen(),
      AppConstants.routeRegister: (context) => const RegistrationScreen(),
      AppConstants.routeSeeder: (context) => const SeederScreen(),

      // Citizen Routes
      AppConstants.routeCitizenDashboard: (context) => const CitizenDashboard(),
      AppConstants.routeCitizenProfile: (context) =>
          const CitizenProfileScreen(),
      AppConstants.routeMyReports: (context) => const MyReportsScreen(),
      AppConstants.routeReportIssue: (context) => const ReportIssueScreen(),

      // Admin Route
      AppConstants.routeAdminDashboard: (context) => const HomeScreen(),
    };
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Handle officer dashboard route with parameters
    if (settings.name == AppConstants.routeOfficerDashboard) {
      // Check for arguments passed during navigation (e.g., from role switcher)
      String role = initialUserRole ?? 'JE';
      String name = initialUserName ?? 'Officer';
      
      if (settings.arguments != null && settings.arguments is Map) {
        final args = settings.arguments as Map;
        role = args['role'] ?? role;
        name = args['name'] ?? name;
      }
      
      return MaterialPageRoute(
        builder: (context) => _getOfficerDashboard(role, name),
      );
    }

    // Handle unknown routes
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Route "${settings.name}" not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.routeHome,
                  (route) => false,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get officer dashboard widget based on role
  /// Hierarchy: CE (District) -> SE (Circle) -> EE/DyEE (Region) -> AE/JE/FE (Office)
  Widget _getOfficerDashboard(String role, String name) {
    switch (role.toUpperCase()) {
      case 'FE':
        return FEDashboardScreen(userRole: role, userName: name);
      case 'JE':
        return JEDashboardScreen(userRole: role, userName: name);
      case 'AE':
        return AEDashboardScreen(userRole: role, userName: name);
      case 'DYEE':
        return DyEEDashboardScreen(userRole: role, userName: name);
      case 'EE':
        return EEDashboardScreen(userRole: role, userName: name);
      case 'SE':
        return SEDashboardScreen(userRole: role, userName: name);
      case 'CE':
        return CEDashboardScreen(userRole: role, userName: name);
      default:
        return FEDashboardScreen(userRole: 'FE', userName: name);
    }
  }
}
