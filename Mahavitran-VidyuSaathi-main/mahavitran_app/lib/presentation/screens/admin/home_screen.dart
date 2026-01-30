import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/admin/theme_provider.dart';
import '../../widgets/admin/header/app_header.dart';
import '../../widgets/admin/sidebar/app_sidebar.dart';
import '../../constants/app_colors.dart';
import 'analytics_screen.dart';
import 'complaints_screen.dart';
import 'escalations_screen.dart';
import 'staff_management_screen.dart';
import 'reports_screen.dart';

enum AdminPage {
  dashboard,
  staffManagement,
  complaints,
  escalations,
  reports,
  settings,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminPage _currentPage = AdminPage.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppHeader(
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onNotificationPressed: () {
          _showNotificationsPanel(context);
        },
        notificationCount: 3,
      ),
      drawer: AppSidebar(
        items: [
          MenuItem(
            label: 'Dashboard',
            icon: Icons.dashboard,
            isActive: _currentPage == AdminPage.dashboard,
            onTap: () {
              _navigateTo(AdminPage.dashboard);
            },
          ),
          MenuItem(
            label: 'Staff Management',
            icon: Icons.people,
            isActive: _currentPage == AdminPage.staffManagement,
            onTap: () {
              _navigateTo(AdminPage.staffManagement);
            },
          ),
          MenuItem(
            label: 'Complaints',
            icon: Icons.description,
            isActive: _currentPage == AdminPage.complaints,
            onTap: () {
              _navigateTo(AdminPage.complaints);
            },
          ),
          MenuItem(
            label: 'Escalations',
            icon: Icons.warning,
            isActive: _currentPage == AdminPage.escalations,
            onTap: () {
              _navigateTo(AdminPage.escalations);
            },
          ),
          MenuItem(
            label: 'Reports',
            icon: Icons.bar_chart,
            isActive: _currentPage == AdminPage.reports,
            onTap: () {
              _navigateTo(AdminPage.reports);
            },
          ),
          MenuItem(
            label: 'Settings',
            icon: Icons.settings,
            isActive: _currentPage == AdminPage.settings,
            onTap: () {
              _navigateTo(AdminPage.settings);
            },
          ),
        ],
        onClose: null,
      ),
      body: _buildCurrentPage(),
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
        return _buildReportsPage();
      case AdminPage.settings:
        return _buildSettingsPage();
    }
  }

  Widget _buildReportsPage() {
    return const ReportsScreen();
  }

  Widget _buildSettingsPage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Enable dark theme for the dashboard',
                                style: TextStyle(
                                  fontSize: AppFontSizes.sm,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                            ],
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, provider, _) {
                              return Switch(
                                value: provider.isDarkMode,
                                onChanged: (value) {
                                  provider.toggleTheme();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildNotificationItem(
                'Critical Escalation',
                'Complaint C2024-002 escalated by Priya Sharma',
                Icons.warning,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildNotificationItem(
                'New Assignment',
                'Complaint C2024-008 assigned to Sneha Patil',
                Icons.assignment_ind,
                AppColors.lightPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildNotificationItem(
                'Overdue Complaint',
                'Complaint C2024-005 pending for 6+ days',
                Icons.schedule,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: AppFontWeights.bold,
                    fontSize: AppFontSizes.sm,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: AppFontSizes.xs,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
