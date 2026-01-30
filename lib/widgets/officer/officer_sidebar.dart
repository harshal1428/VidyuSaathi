import 'package:flutter/material.dart';
import '../../screens/Officer/pages/officer_all_tickets_screen.dart';
import '../../screens/Officer/pages/officer_team_screen.dart';
import '../../screens/officer/cluster_list_screen.dart';
import '../../screens/Officer/pages/officer_reports_screen.dart';
import '../../screens/Officer/pages/officer_profile_screen.dart';
import '../../screens/Officer/pages/officer_settings_screen.dart';
import 'package:vidyusaathi/widgets/common/role_switcher.dart';
import 'package:vidyusaathi/constants/app_colors.dart';

class OfficerSidebar extends StatelessWidget {
  final String userName;
  final String userRole;
  final String teamLabel;
  final bool isDark;
  final VoidCallback onLogout;

  const OfficerSidebar({
    Key? key,
    required this.userName,
    required this.userRole,
    this.teamLabel = 'Team', // Default value
    required this.isDark,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSidebar : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: const TextStyle(color: Colors.white)),
            accountEmail: Text(userRole, style: const TextStyle(color: Colors.white70)),
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
          _buildDrawerItem(
            context,
            Icons.dashboard,
            'Dashboard',
            () => Navigator.pop(context),
            isDark: isDark,
          ),
          _buildDrawerItem(
            context,
            Icons.receipt_long,
            'All Tickets',
            () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfficerAllTicketsScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildDrawerItem(
            context,
            Icons.people,
            teamLabel,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfficerTeamScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildDrawerItem(
            context,
            Icons.analytics,
            'Reports',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfficerReportsScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildDrawerItem(
            context,
            Icons.hub,
            'Complaint Clusters',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClusterListScreen()),
              );
            },
            isDark: isDark,
          ),
          Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
          _buildDrawerItem(
            context,
            Icons.person,
            'Profile',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfficerProfileScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildDrawerItem(
            context,
            Icons.settings,
            'Settings',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfficerSettingsScreen()),
              );
            },
            isDark: isDark,
          ),
          Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
          _buildDrawerItem(
            context,
            Icons.logout,
            'Logout',
            onLogout,
            isLogout: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
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
}


