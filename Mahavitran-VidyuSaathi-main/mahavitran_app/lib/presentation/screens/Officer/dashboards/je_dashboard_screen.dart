import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'officer_dashboard.dart';
import '../sections/je_dashboard_section.dart';
import '../../../widgets/common/role_switcher.dart';
import '../../../provider/admin/theme_provider.dart';
import '../../../constants/app_colors.dart';
import '../pages/officer_all_tickets_screen.dart';
import '../pages/officer_team_screen.dart';
import '../pages/officer_reports_screen.dart';
import '../pages/officer_profile_screen.dart';
import '../pages/officer_settings_screen.dart';
import '../pages/officer_task_management_screen.dart';

/// Junior Engineer Dashboard Screen
/// Field operations focused - SCADA verification, field work tracking, task management
class JEDashboardScreen extends OfficerDashboardTemplate {
  const JEDashboardScreen({
    Key? key,
    required String userRole,
    required String userName,
  }) : super(
          key: key,
          userRole: userRole,
          userName: userName,
        );

  @override
  State<JEDashboardScreen> createState() => _JEDashboardScreenState();

  @override
  Widget buildRoleSpecificContent(BuildContext context) {
    return const JEDashboardSection();
  }

  @override
  String getDashboardTitle() => 'Junior Engineer Dashboard';
}

class _JEDashboardScreenState extends State<JEDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Junior Engineer Dashboard'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          // Dark mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: _buildSidebar(isDark),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: JEDashboardSection(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new task/ticket
        },
        backgroundColor: isDark ? AppColors.darkSidebarPrimary : const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSidebar : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.userName,
              style: const TextStyle(color: Colors.white),
            ),
            accountEmail: const Text(
              'Junior Engineer',
              style: TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Color(0xFF1976D2)),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                    : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }, isDark: isDark),
          _buildDrawerItem(Icons.receipt_long, 'All Tickets', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerAllTicketsScreen()),
            );
          }, isDark: isDark),
          _buildDrawerItem(Icons.people, 'Field Officers (3)', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerTeamScreen()),
            );
          }, isDark: isDark),
          _buildDrawerItem(Icons.assignment, 'Task Management', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerTaskManagementScreen()),
            );
          }, isDark: isDark),
          _buildDrawerItem(Icons.analytics, 'Reports', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerReportsScreen()),
            );
          }, isDark: isDark),
          Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
          _buildDrawerItem(Icons.person, 'Profile', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerProfileScreen()),
            );
          }, isDark: isDark),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfficerSettingsScreen()),
            );
          }, isDark: isDark),
          Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
          // Role Switcher for development/testing
          const RoleSwitcher(),
          Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
          _buildDrawerItem(
            Icons.logout,
            'Logout',
            () {
              _showLogoutConfirmation(isDark);
            },
            isLogout: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isLogout 
            ? Colors.red 
            : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout 
              ? Colors.red 
              : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
          fontWeight: isLogout ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
