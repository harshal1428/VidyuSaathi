import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure you have this package or use a text-based alternative if not
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/dashboard_stats_model.dart';
import '../../services/auth_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // For Admin, we might want aggregate stats. 
    // Assuming getTicketStats returns aggregate if user is admin, or we create a specific method.
    // For now we use getTicketStats(user) - assuming admin user gets global stats or we adjust service later.
    
    return StreamBuilder<DashboardStats>(
      stream: dbService.getTicketStats(user!), 
      builder: (context, snapshot) {
        final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 24),

              // Key Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard("Total Complaints", "${stats.total}", Icons.assignment, Colors.blue, isDark),
                  _buildMetricCard("Resolved", "${stats.resolved}", Icons.check_circle, Colors.green, isDark),
                  _buildMetricCard("Pending", "${stats.pending}", Icons.pending, Colors.orange, isDark),
                  _buildMetricCard("Escalated", "${stats.escalated}", Icons.trending_up, Colors.red, isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Complaint Status Distribution",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: stats.total == 0 
                        ? const Center(child: Text("No Data"))
                        : PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: stats.resolved.toDouble(),
                                title: '${stats.resolved}',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: stats.pending.toDouble(),
                                title: '${stats.pending}',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.red,
                                value: stats.escalated.toDouble(),
                                title: '${stats.escalated}',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                               PieChartSectionData(
                                color: Colors.blue,
                                value: (stats.total - stats.resolved - stats.pending - stats.escalated).toDouble(), 
                                title: '${(stats.total - stats.resolved - stats.pending - stats.escalated)}',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
