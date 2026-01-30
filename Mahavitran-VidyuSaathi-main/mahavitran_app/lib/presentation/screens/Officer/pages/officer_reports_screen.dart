import 'package:flutter/material.dart';
import 'package:mahavitran_app/presentation/constants/app_colors.dart';

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

            // Charts Placeholder
            Container(
              width: double.infinity,
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 300), // Min width to look good
                      child: SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width - (AppSpacing.lg * 4), // Dynamic width
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

             // Tickets by Category
            Text(
              'Tickets by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryStat('Power Outage', 45, 0.7, Colors.orange, isDark),
            _buildCategoryStat('Voltage Fluctuation', 28, 0.45, Colors.blue, isDark),
            _buildCategoryStat('Meter Issue', 15, 0.3, Colors.purple, isDark),
            _buildCategoryStat('Billing', 10, 0.2, Colors.green, isDark),

            const SizedBox(height: AppSpacing.xl),

            // Recent Critical Tickets
            Text(
              'Recent Critical Tickets',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
             ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.statusCritical.withOpacity(0.1),
                      child: const Icon(Icons.warning, color: AppColors.statusCritical, size: 20),
                    ),
                    title: Text(
                      'Ticket #C2024-10$index',
                      style: TextStyle(
                         fontWeight: AppFontWeights.medium,
                         color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    subtitle: Text(
                      'Substation failure in Sector ${4 + index}',
                       style: TextStyle(
                         color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                         fontSize: AppFontSizes.xs,
                      ),
                    ),
                    trailing: Text(
                      '2h ago',
                      style: TextStyle(
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        fontSize: AppFontSizes.xs,
                      ),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStat(String label, int count, double percentage, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                 style: TextStyle(
                   fontSize: AppFontSizes.sm,
                   color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                   fontWeight: AppFontWeights.medium,
                 ),
              ),
              Text(
                '$count',
                style: TextStyle(
                   fontSize: AppFontSizes.sm,
                   color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
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
          FittedBox( // Prevents overflow for large numbers
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppFontSizes.xxl,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
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
