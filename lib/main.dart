import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'screens/auth/home_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/citizen/citizen_dashboard.dart';
import 'screens/citizen/citizen_profile_screen.dart';
import 'screens/citizen/report_issue_screen.dart';
import 'screens/citizen/my_reports_screen.dart';
import 'screens/officer/officer_dashboard.dart';
import 'screens/officer/task_management_screen.dart';
import 'screens/auth/seeder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  // Note: In a real app, you'd use the generated firebase_options.dart
  // For this implementation task, we assume it's set up or use a placeholder.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // We continue running the app. The Auth/Database access will fail gracefully later if needed,
    // or retry logic should be handled there.
  }

  runApp(const VidyuSaathiApp());
}

class VidyuSaathiApp extends StatelessWidget {
  const VidyuSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..initialize()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'VidyuSaathi',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/citizen_dashboard': (context) => const CitizenDashboard(),
          '/citizen_profile': (context) => const CitizenProfileScreen(),
          '/report_issue': (context) => const ReportIssueScreen(),
          '/my_reports': (context) => const MyReportsScreen(),
          '/officer_dashboard': (context) => const OfficerDashboard(),
          '/officer_tasks': (context) => const TaskManagementScreen(),
          '/seeder': (context) => const SeederScreen(),
        },
      ),
    );
  }
}
