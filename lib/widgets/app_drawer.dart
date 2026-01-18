import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          if (user?.role == AppConstants.roleCitizen) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Citizen Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/citizen_profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                // Already on dashboard or navigate back
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/report_issue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_reports');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
