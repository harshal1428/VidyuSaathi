import 'package:flutter/material.dart';

/// Officer Dashboard Template
/// Abstract base class for all officer role dashboards
/// Provides common UI elements: AppBar with notifications, Sidebar navigation, Logout, Refresh
///
/// Subclasses override buildRoleSpecificContent() to provide role-specific content
abstract class OfficerDashboardTemplate extends StatefulWidget {
  final String userRole;
  final String userName;

  const OfficerDashboardTemplate({
    Key? key,
    required this.userRole,
    required this.userName,
  }) : super(key: key);

  @override
  State<OfficerDashboardTemplate> createState() =>
      _OfficerDashboardTemplateState();

  /// Override this method to provide role-specific dashboard content
  Widget buildRoleSpecificContent(BuildContext context);

  /// Override to customize dashboard title
  String getDashboardTitle() => '$userRole Dashboard';
}

class _OfficerDashboardTemplateState extends State<OfficerDashboardTemplate> {
  final int _notificationCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildSidebar(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role-specific content
              widget.buildRoleSpecificContent(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// App Bar with notifications and profile
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.getDashboardTitle()),
      elevation: 0,
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (_notificationCount > 0)
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
                      _notificationCount.toString(),
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
            // TODO: Navigate to notifications screen
          },
        ),

        // Profile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /// Navigation Sidebar / Drawer
  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName),
            accountEmail: Text(widget.userRole),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.receipt_long, 'All Tickets', () {
            // TODO: Navigate to tickets
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.assignment, 'Task Management', () {
            // TODO: Navigate to task management
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.analytics, 'Reports', () {
            // TODO: Navigate to reports
            Navigator.pop(context);
          }),
          const Divider(),
          _buildDrawerItem(Icons.person, 'Profile', () {
            // TODO: Navigate to profile
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            // TODO: Navigate to settings
            Navigator.pop(context);
          }),
          const Divider(),
          _buildDrawerItem(
            Icons.logout,
            'Logout',
            () {
              _showLogoutConfirmation(context);
            },
            isLogout: true,
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
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
          fontWeight: isLogout ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement logout logic
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

  /// Floating Action Button
  Widget? _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to create ticket/task
      },
      child: const Icon(Icons.add),
    );
  }

  Future<void> _refreshDashboard() async {
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 1));
  }
}



