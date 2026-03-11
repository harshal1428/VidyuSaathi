import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'provider/admin/theme_provider.dart';
import 'provider/admin/analytics_provider.dart';
import 'screens/auth/home_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/citizen/citizen_dashboard.dart';
import 'screens/citizen/citizen_profile_screen.dart';
import 'screens/citizen/report_issue_screen.dart';
import 'screens/citizen/my_reports_screen.dart';
import 'screens/officer/officer_dashboard.dart';
import 'screens/admin/home_screen.dart' as admin;
import 'screens/auth/seeder_screen.dart';
import 'services/notification_service.dart';
import 'widgets/notification_wrapper.dart';
import 'services/local_notification_service.dart';
import 'screens/officer/task_management_screen.dart';
import 'widgets/auth_wrapper.dart';

import 'core/navigation_key.dart';
import 'screens/common/ticket_redirect_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Local Notifications
  await LocalNotificationService.initialize();
  
  runApp(const VidyuSaathiApp());
}

class VidyuSaathiApp extends StatelessWidget {
  const VidyuSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthService>(
        builder: (context, themeProvider, authService, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Vidyut SurakshaSaathi',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
            builder: (context, child) {
              // Wrap the entire Navigator with NotificationWrapper
              return NotificationWrapper(child: child!);
            },
            routes: {
              '/home': (context) => const HomePage(), // Renamed / to /home since home is now AuthWrapper
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/citizen_dashboard': (context) => const CitizenDashboard(),
              '/citizen_profile': (context) => const CitizenProfileScreen(),
              '/report_issue': (context) => const ReportIssueScreen(),
              '/my_reports': (context) => const MyReportsScreen(),
              '/officer_dashboard': (context) => const OfficerDashboard(),
              '/admin_dashboard': (context) => const admin.AdminHomeScreen(),
              '/officer_tasks': (context) => const TaskManagementScreen(),
              '/seeder': (context) => const SeederScreen(),
              '/ticket_redirect': (context) {
                 final args = ModalRoute.of(context)!.settings.arguments as String;
                 return TicketRedirectScreen(ticketId: args);
              },
            },
          );
        },
      ),
    );
  }
}
