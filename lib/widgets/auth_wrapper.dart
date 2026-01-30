import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';
import '../screens/auth/home_page.dart';
import '../screens/citizen/citizen_dashboard.dart';
import '../screens/officer/officer_dashboard.dart';
import '../screens/admin/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading your profile..."),
            ],
          ),
        ),
      );
    }

    if (authService.currentUser != null) {
      final role = authService.currentUser!.role;
      if (role == AppConstants.roleCitizen) {
        return const CitizenDashboard();
      } else if (role == AppConstants.roleAdmin) {
        return const AdminHomeScreen();
      } else {
        // Assume Officer (role == 'OFFICER' or specific designation)
        // Check if role is effectively officer
        return const OfficerDashboard();
      }
    }

    return const HomePage();
  }
}
