import 'package:flutter/material.dart';
import '../../../../presentation/constants/app_colors.dart';

/// SE (Superintending Engineer) Dashboard Section
/// Simplified to show only DB-schema aligned data
class SEDashboardSection extends StatefulWidget {
  const SEDashboardSection({Key? key}) : super(key: key);

  @override
  State<SEDashboardSection> createState() => _SEDashboardSectionState();
}

class _SEDashboardSectionState extends State<SEDashboardSection> {
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

          // Regional Offices Overview
          _buildRegionalOfficesOverview(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Regional Tickets
          _buildRegionalTickets(isDark),
          const SizedBox(height: AppSpacing.lg),

          // Offices Overview
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
            'Superintending Engineer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Regional operations and strategic oversight',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalOfficesOverview(bool isDark) {
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
                'Regional Staff',
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
                  title: 'EE Count',
                  value: '5',
                  icon: Icons.engineering,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'DyEE Count',
                  value: '15',
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
                  title: 'AE Count',
                  value: '60',
                  icon: Icons.people,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'JE Count',
                  value: '480',
                  icon: Icons.groups,
                  color: Colors.teal,
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
                  title: 'Total Staff',
                  value: '560',
                  icon: Icons.people_alt,
                  color: Colors.indigo,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Active',
                  value: '552',
                  icon: Icons.check_circle,
                  color: Colors.orange,
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

  Widget _buildRegionalTickets(bool isDark) {
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
                'Regional Tickets',
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
                  value: '425',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'In Progress',
                  value: '350',
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
                  value: '5240',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '6015',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'By Category',
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
                child: _buildCategoryTag('Power', 285, Colors.orange),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCategoryTag('Billing', 320, Colors.blue),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildCategoryTag('Infrastructure', 170, Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(String category, int count, Color color) {
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
            category,
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: color,
              fontWeight: AppFontWeights.semiBold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficesOverview(bool isDark) {
    // Example data, replace with actual data source
    final List<Map<String, dynamic>> regions = [
      {
        'name': 'Shivajinagar Region',
        'ee': 'Mr. S. EE',
        'dyee': 'Ms. S. DyEE',
        'divisionOffices': [
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
        ],
      },
      {
        'name': 'Swargate Region',
        'ee': 'Mr. Sw. EE',
        'dyee': 'Ms. Sw. DyEE',
        'divisionOffices': [
          {
            'name': 'Swargate Division Office',
            'je': 'JE3',
            'ae': 'AE3',
            'fes': ['FE7', 'FE8', 'FE9'],
          },
          {
            'name': 'Katraj Division Office',
            'je': 'JE4',
            'ae': 'AE4',
            'fes': ['FE10', 'FE11', 'FE12'],
          },
        ],
      },
      // Add more regions as needed
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
                'Regions in Circle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...regions.map((region) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      region['name'],
                      style: const TextStyle(fontSize: AppFontSizes.base, fontWeight: AppFontWeights.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Chip(
                      label: Text('EE: ${region['ee']}\nDyEE: ${region['dyee']}',
                          style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                      backgroundColor: Colors.blue.shade50,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              ...region['divisionOffices'].map<Widget>((office) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(office['name'], style: const TextStyle(fontSize: AppFontSizes.sm, fontWeight: AppFontWeights.semiBold)),
                    Text('JE: ${office['je']}'),
                    Text('AE: ${office['ae']}'),
                    Text('Field Officers: ${office['fes'].join(", ")}'),
                    Divider(color: Colors.grey.shade200),
                  ],
                ),
              )),
              Divider(height: 24, thickness: 1, color: Colors.indigo.shade100),
            ],
          )),
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
                  value: '28',
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Sent to CE',
                  value: '8',
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
            ticketId: '#4560',
            fromRole: 'EE',
            toRole: 'SE',
            reason: 'Regional coordination required',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildEscalationItem(
            ticketId: '#4555',
            fromRole: 'SE',
            toRole: 'CE',
            reason: 'Organization-wide policy decision',
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
