import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth/auth_service.dart';
import '../../../data/services/citizen/citizen_database_service.dart';
import '../../../domain/models/citizen/user_model.dart';
import '../../widgets/citizen/citizen_app_drawer.dart';

/// Dashboard screen for citizens
class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  late UserModel _displayUser;

  @override
  void initState() {
    super.initState();
    // Create a default mock user for testing without Firebase
    _displayUser = UserModel(
      userId: 'test_user_001',
      name: 'Test Citizen',
      email: 'test@example.com',
      phone: '9876543210',
      role: AppConstants.roleCitizen,
      createdAt: DateTime.now(),
      address: 'Pune, Maharashtra',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser ?? _displayUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      drawer: const CitizenAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firebase Status Banner (only show when not connected)
            if (!authService.isFirebaseReady)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Running in demo mode (Firebase not configured)',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('How can we help you today?'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context, user.userId),

            const SizedBox(height: 24),

            // Action Buttons
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DashboardButton(
                  icon: Icons.report_problem,
                  label: 'Report Issue',
                  description: 'Report a new problem',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppConstants.routeReportIssue,
                  ),
                ),
                _DashboardButton(
                  icon: Icons.history,
                  label: 'My Reports',
                  description: 'View your complaints',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppConstants.routeMyReports,
                  ),
                ),
                _DashboardButton(
                  icon: Icons.person,
                  label: 'Profile',
                  description: 'Manage your account',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppConstants.routeCitizenProfile,
                  ),
                ),
                _DashboardButton(
                  icon: Icons.help_outline,
                  label: 'Help',
                  description: 'Get assistance',
                  color: Colors.purple,
                  onTap: () => _showHelpDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Emergency Contact
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.emergency, color: Colors.red),
                ),
                title: const Text(
                  'Emergency Helpline',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('1912 (24x7)'),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling emergency helpline...'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, String userId) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // If Firebase is not ready, show mock stats
    if (!authService.isFirebaseReady) {
      return _buildMockStats();
    }
    
    final dbService = CitizenDatabaseService();

    return FutureBuilder<Map<String, int>>(
      future: dbService.getCitizenTicketCounts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final counts = snapshot.data ?? {'total': 0};

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total',
                count: counts['total'] ?? 0,
                color: Colors.blue,
                icon: Icons.list_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Pending',
                count: (counts[AppConstants.statusCreated] ?? 0) +
                    (counts[AppConstants.statusAssigned] ?? 0) +
                    (counts[AppConstants.statusInProgress] ?? 0),
                color: Colors.orange,
                icon: Icons.pending,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Resolved',
                count: (counts[AppConstants.statusResolved] ?? 0) +
                    (counts[AppConstants.statusClosed] ?? 0),
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build mock stats for demo mode when Firebase is not available
  Widget _buildMockStats() {
    return Row(
      children: [
        const Expanded(
          child: _StatCard(
            title: 'Total',
            count: 5,
            color: Colors.blue,
            icon: Icons.list_alt,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            title: 'Pending',
            count: 2,
            color: Colors.orange,
            icon: Icons.pending,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            title: 'Resolved',
            count: 3,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No new notifications'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('For assistance, you can:'),
            const SizedBox(height: 12),
            _helpItem(Icons.phone, 'Call Helpline: 1912'),
            _helpItem(Icons.email, 'Email: support@mahavitran.in'),
            _helpItem(Icons.language, 'Website: mahavitran.in'),
          ],
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

  Widget _helpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
