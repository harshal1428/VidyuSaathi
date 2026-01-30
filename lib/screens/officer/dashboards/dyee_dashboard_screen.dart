import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../officer_dashboard.dart';
import '../sections/dyee_dashboard_section.dart';
import '../../../widgets/common/role_switcher.dart';
import '../../../provider/admin/theme_provider.dart';
import '../../../constants/app_colors.dart';
import 'package:vidyusaathi/widgets/officer/officer_sidebar.dart';
import '../../common/notifications_screen.dart';
import '../../../services/auth_service.dart';

/// Deputy Executive Engineer Dashboard Screen
/// Division management focused - subdivision overview, team management, SLA metrics, escalations
class DyEEDashboardScreen extends OfficerDashboardTemplate {
  const DyEEDashboardScreen({
    Key? key,
    required String userRole,
    required String userName,
  }) : super(
          key: key,
          userRole: userRole,
          userName: userName,
        );

  @override
  State<DyEEDashboardScreen> createState() => _DyEEDashboardScreenState();

  @override
  Widget buildRoleSpecificContent(BuildContext context) {
    return const DyEEDashboardSection();
  }

  @override
  String getDashboardTitle() => 'Deputy Executive Engineer Dashboard';
}

class _DyEEDashboardScreenState extends State<DyEEDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        appBar: AppBar(
          title: const Text('Deputy Executive Engineer Dashboard'),
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          actions: [
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
                        '7',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
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
        drawer: OfficerSidebar(
          userName: widget.userName,
          userRole: 'Deputy Executive Engineer',
          teamLabel: 'AE Team',
          isDark: isDark,
          onLogout: () => _showLogoutConfirmation(isDark),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: DyEEDashboardSection(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: isDark ? AppColors.darkSidebarPrimary : const Color(0xFF1976D2),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('Logout',
            style: TextStyle(
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          TextButton(
              onPressed: () {
                // Perform Logout
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}



