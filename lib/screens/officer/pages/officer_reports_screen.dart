import 'package:flutter/material.dart';
import 'package:vidyusaathi/constants/app_colors.dart';

class OfficerReportsScreen extends StatefulWidget {
  const OfficerReportsScreen({Key? key}) : super(key: key);

  @override
  State<OfficerReportsScreen> createState() => _OfficerReportsScreenState();
}

class _OfficerReportsScreenState extends State<OfficerReportsScreen> {
  // Mock data for report metrics
  final int totalComplaints = 145;
  final int criticalComplaints = 12;
  final int resolvedComplaints = 118;
  final double avgResolutionTime = 2.8;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
         title: const Text('Reports & Analytics'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Export button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                     Text(
                      'Complaint statistics for your jurisdiction',
                      style: TextStyle(
                        fontSize: AppFontSizes.sm,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting report...')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Key Metrics Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  'Total Tickets',
                  totalComplaints.toString(),
                  Icons.description,
                  AppColors.statusInfo,
                  isDark,
                ),
                _buildMetricCard(
                  'Critical',
                  criticalComplaints.toString(),
                  Icons.error,
                  AppColors.statusCritical,
                  isDark,
                ),
                _buildMetricCard(
                  'Resolved',
                  resolvedComplaints.toString(),
                  Icons.check_circle,
                  AppColors.statusNormal,
                  isDark,
                ),
                _buildMetricCard(
                  'Avg Time',
                  '${avgResolutionTime} days',
                  Icons.timer,
                  AppColors.chart2Light,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Charts Placeholder (Simulated)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Ticket Trend',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTrendBar('Mon', 12, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Tue', 15, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Wed', 8, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Thu', 18, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Fri', 14, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Sat', 6, 20, AppColors.statusInfo, isDark),
                        _buildTrendBar('Sun', 4, 20, AppColors.statusInfo, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSizes.sm,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.xxl,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String label, int value, int maxValue, Color color, bool isDark) {
    final heightRatio = (value / maxValue).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 150 * heightRatio,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.xs,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }
}


