import 'package:flutter/material.dart';
import '../../../../presentation/constants/app_colors.dart';

/// EE (Executive Engineer) Dashboard Section
/// Simplified to show only DB-schema aligned data
class EEDashboardSection extends StatefulWidget {
  const EEDashboardSection({Key? key}) : super(key: key);

  @override
  State<EEDashboardSection> createState() => _EEDashboardSectionState();
}

class _EEDashboardSectionState extends State<EEDashboardSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Circle Officers Overview
          _buildCircleOfficersOverview(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Circle Tickets
          _buildCircleTickets(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Offices in Circle
          _buildOfficesOverview(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Escalations
          _buildEscalationsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive Engineer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Circle management and coordination',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleOfficersOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
          Row(
            children: [
              Icon(Icons.group, color: AppColors.statusInfo),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Circle Officers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'DyEE Count',
                  value: '3',
                  icon: Icons.engineering,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'AE Count',
                  value: '12',
                  icon: Icons.person_outline,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'JE Count',
                  value: '96',
                  icon: Icons.people,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Staff',
                  value: '111',
                  icon: Icons.groups,
                  color: Colors.teal,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.xxxl,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              fontWeight: AppFontWeights.medium,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleTickets(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.statusInfo),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Circle-wide Tickets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: '125',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'In Progress',
                  value: '98',
                  icon: Icons.hourglass_top,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Completed',
                  value: '1245',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '1468',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'By Priority',
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildPriorityTag('High', 45, Colors.red),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPriorityTag('Medium', 95, Colors.orange),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPriorityTag('Low', 83, Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTag(String priority, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: AppFontSizes.lg,
              fontWeight: AppFontWeights.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            priority,
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: color,
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficesOverview(bool isDark) {
    // Example data, replace with actual data source
    final List<Map<String, dynamic>> divisionOffices = [
      {
        'name': 'Shivajinagar Division Office',
        'je': 'JE1',
        'ae': 'AE1',
        'fes': ['FE1', 'FE2', 'FE3'],
      },
      {
        'name': 'Aundh Division Office',
        'je': 'JE2',
        'ae': 'AE2',
        'fes': ['FE4', 'FE5', 'FE6'],
      },
      // Add more offices as needed
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
          Row(
            children: [
              Icon(Icons.business, color: Colors.indigo),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Division Offices in Region',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...divisionOffices.map((office) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                office['name'],
                style: const TextStyle(fontSize: AppFontSizes.base, fontWeight: AppFontWeights.bold),
              ),
              const SizedBox(height: 4),
              Text('JE: ${office['je']}'),
              Text('AE: ${office['ae']}'),
              Text('Field Officers: ${office['fes'].join(", ")}'),
              Divider(height: 24, thickness: 1, color: Colors.indigo.shade100),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildOfficeItem({
    required String name,
    required String level,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.business, color: Colors.indigo),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppFontSizes.sm,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: AppFontSizes.xs,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.red),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Escalations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Received',
                  value: '12',
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Sent to SE',
                  value: '5',
                  icon: Icons.arrow_upward,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent Escalations',
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildEscalationItem(
            ticketId: '#3450',
            fromRole: 'DyEE',
            toRole: 'EE',
            reason: 'Circle level decision required',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildEscalationItem(
            ticketId: '#3445',
            fromRole: 'EE',
            toRole: 'SE',
            reason: 'Regional coordination needed',
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationItem({
    required String ticketId,
    required String fromRole,
    required String toRole,
    required String reason,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: Colors.red.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700]),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Ticket $ticketId',
                  style: const TextStyle(
                    fontSize: AppFontSizes.sm,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$fromRole → $toRole',
                  style: const TextStyle(
                    fontSize: AppFontSizes.xs,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reason,
            style: TextStyle(fontSize: AppFontSizes.xs, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
