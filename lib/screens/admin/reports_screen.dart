import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/dashboard_stats_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming admin sees global stats or own stats? Admin usually global.
    // For now we use the current user from auth which should be Admin.
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
       body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
                'System Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightPrimary),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: StreamBuilder<DashboardStats>(
                 stream: dbService.getTicketStats(user),
                 builder: (context, snapshot) {
                   if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                   
                   final stats = snapshot.data!;
                   
                   return GridView.count(
                     crossAxisCount: 2,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                     children: [
                       _buildReportCard(
                         context: context,
                         icon: Icons.picture_as_pdf,
                         title: "Pending Tickets",
                         subtitle: "${stats.pending} Tickets",
                         color: Colors.red,
                         onTap: () {},
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.bar_chart,
                         title: "Resolved Performance",
                         subtitle: "${stats.resolved} Resolved",
                         color: Colors.blue,
                         onTap: () {},
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.pie_chart,
                         title: "Total Volume",
                         subtitle: "${stats.total} Complaints",
                         color: Colors.orange,
                         onTap: () {},
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.table_chart,
                         title: "Escalations",
                         subtitle: "${stats.escalated} Escalated",
                         color: Colors.purple,
                         onTap: () {},
                       ),
                     ],
                   );
                 }
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Downloading $title Report... (Mocked)'))
            );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text("Download", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
