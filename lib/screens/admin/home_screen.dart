import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'analytics_screen.dart';
import 'staff_management_screen.dart';
import 'complaints_screen.dart';
import 'escalations_screen.dart';
import 'reports_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/logout_confirmation_wrapper.dart';

// Enum for navigation
enum AdminPage {
  dashboard,
  staffManagement,
  complaints,
  escalations,
  reports,
  settings,
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminPage _currentPage = AdminPage.dashboard;

  @override
  Widget build(BuildContext context) {
    // Basic Layout for Admin Dashboard
    return LogoutConfirmationWrapper(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Admin Portal'),
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
        ),
        drawer: _buildDrawer(),
        body: _buildCurrentPage(),
      ),
    );
  }

  Widget _buildDrawer() {
    final user = Provider.of<AuthService>(context).currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.lightPrimary),
            accountName: Text(user?.name.isNotEmpty == true ? user!.name : 'Admin User'),
            accountEmail: Text(
              (user?.officeId ?? '').isNotEmpty
                  ? '${user!.email}\nOffice: ${user.officeId}'
                  : (user?.email ?? 'admin@mahavitran.in'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _currentPage == AdminPage.dashboard,
            onTap: () => _navigateTo(AdminPage.dashboard),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Staff Management'),
            selected: _currentPage == AdminPage.staffManagement,
            onTap: () => _navigateTo(AdminPage.staffManagement),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Complaints'),
            selected: _currentPage == AdminPage.complaints,
            onTap: () => _navigateTo(AdminPage.complaints),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Escalations'),
            selected: _currentPage == AdminPage.escalations,
            onTap: () => _navigateTo(AdminPage.escalations),
          ),
          // Add other menu items as needed
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            selected: _currentPage == AdminPage.reports,
            onTap: () => _navigateTo(AdminPage.reports),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
               Provider.of<AuthService>(context, listen: false).logout();
               Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(AdminPage page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case AdminPage.dashboard:
        return const AnalyticsScreen();
      case AdminPage.staffManagement:
        return const StaffManagementScreen();
      case AdminPage.complaints:
        return const ComplaintsScreen();
      case AdminPage.escalations:
        return const EscalationsScreen();
      case AdminPage.reports:
         return const ReportsScreen();
      case AdminPage.settings:
        return const Center(child: Text("Settings Screen Placeholder"));
    }
  }
}
