import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../officer_dashboard.dart';
import '../sections/se_dashboard_section.dart';
import '../../../widgets/common/role_switcher.dart';
import '../../../provider/admin/theme_provider.dart';
import '../../../constants/app_colors.dart';
import 'package:vidyusaathi/widgets/officer/officer_sidebar.dart';
import '../../common/notifications_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

/// Superintending Engineer Dashboard Screen
/// Strategic analytics - regional operations, multi-circle tracking, budget oversight
class SEDashboardScreen extends OfficerDashboardTemplate {
  const SEDashboardScreen({
    Key? key,
    required String userRole,
    required String userName,
  }) : super(
          key: key,
          userRole: userRole,
          userName: userName,
        );

  @override
  State<SEDashboardScreen> createState() => _SEDashboardScreenState();

  @override
  Widget buildRoleSpecificContent(BuildContext context) {
    return const SEDashboardSection();
  }

  @override
  String getDashboardTitle() => 'Superintending Engineer Dashboard';
}

class _SEDashboardScreenState extends State<SEDashboardScreen> {
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
          title: const Text('Superintending Engineer Dashboard'),
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            ),
            // Notification Icon
            Consumer<AuthService>(
              builder: (context, auth, _) {
                final user = auth.currentUser;
                if (user == null) {
                   return IconButton(
                     icon: const Icon(Icons.notifications_outlined),
                     onPressed: () {},
                   );
                }
                return StreamBuilder<int>(
                  stream: Provider.of<NotificationService>(context).getUnreadCount(user.userId),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined),
                          if (count > 0)
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
                                child: Text(
                                  count > 9 ? '9+' : count.toString(),
                                  style: const TextStyle(
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
                    );
                  }
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
          userRole: 'Superintending Engineer',
          teamLabel: 'EE Team',
          isDark: isDark,
          onLogout: () => _showLogoutConfirmation(isDark),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SEDashboardSection(),
          ),
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



