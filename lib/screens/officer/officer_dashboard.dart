import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_drawer.dart';

class OfficerDashboard extends StatelessWidget {
  const OfficerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.designation ?? "Officer"} Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics Section (Generic implementation as per prompt requirements)
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Total Tickets', value: '120', color: Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _MetricCard(label: 'Pending', value: '45', color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Resolved', value: '75', color: Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _MetricCard(label: 'Escalated', value: '5', color: Colors.red)),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text('Task Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Task Management Buttons
            _TaskButton(
              label: 'My Tasks',
              icon: Icons.assignment_ind,
              onTap: () => Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': 'my_tasks'}),
            ),
            _TaskButton(
              label: 'Pending Tasks',
              icon: Icons.pending_actions,
              onTap: () => Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': 'pending'}),
            ),
            _TaskButton(
              label: 'In Progress',
              icon: Icons.run_circle,
              onTap: () => Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': 'in_progress'}),
            ),
            _TaskButton(
              label: 'Completed',
              icon: Icons.check_circle,
              onTap: () => Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': 'completed'}),
            ),

            const SizedBox(height: 24),
            const Text('Other Modules (Not Working)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            
            // "Not Working" Sections
            const _DisabledSection(label: 'Inventory Management'),
            const _DisabledSection(label: 'Staff Attendance'),
            const _DisabledSection(label: 'Maintenance Schedule'),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _TaskButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TaskButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _DisabledSection extends StatelessWidget {
  final String label;

  const _DisabledSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.block, color: Colors.grey),
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        trailing: const Text('Coming Soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }
}
