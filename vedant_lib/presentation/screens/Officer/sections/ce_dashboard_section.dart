import 'package:flutter/material.dart';
import '../../../../presentation/constants/app_colors.dart';

/// CE (Chief Engineer) Dashboard Section
/// Simplified to show only DB-schema aligned data
class CEDashboardSection extends StatefulWidget {
  const CEDashboardSection({Key? key}) : super(key: key);

  @override
  State<CEDashboardSection> createState() => _CEDashboardSectionState();
}


class _CEDashboardSectionState extends State<CEDashboardSection> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> circles = [
      {
        'name': 'Pune Circle',
        'se': 'Mr. P. SE',
        'regions': [
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
        ],
      },
      // Add more circles as needed
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'JE Count',
                  value: '3840',
                  icon: Icons.groups,
                  color: Colors.indigo,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Staff',
                  value: '4488',
                  icon: Icons.people_alt,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),


          // Circles Overview
          Container(
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
                    Icon(Icons.account_balance, color: AppColors.lightPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Circles Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...circles.map((circle) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                circle['name'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('SE: ${circle['se']}',
                                  style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.blue.shade50,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        ...circle['regions'].map<Widget>((region) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, top: 4.0, bottom: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(region['name'],
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          '(EE: ${region['ee']}, DyEE: ${region['dyee']})',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                  ...region['divisionOffices']
                                      .map<Widget>((office) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, top: 4.0, bottom: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(office['name'],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(height: 2),
                                                Text('JE: ${office['je']}'),
                                                Text('AE: ${office['ae']}'),
                                                Text(
                                                    'Field Officers: ${office['fes'].join(", ")}'),
                                                Divider(color: Colors.grey.shade200),
                                              ],
                                            ),
                                          )),
                                  Divider(height: 24, thickness: 1, color: Colors.indigo.shade100),
                                ],
                              ),
                            )),
                        const Divider(),
                      ],
                    )),
              ],
            ),
          ),


          const SizedBox(height: AppSpacing.lg),
          _buildOrganizationTickets(isDark),

          const SizedBox(height: AppSpacing.lg),
          _buildAllOfficesOverview(isDark),

          const SizedBox(height: AppSpacing.lg),
          _buildEscalationsSection(isDark),
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

  Widget _buildOrganizationTickets(bool isDark) {
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
                'Organization-wide Tickets',
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
                  value: '3,420',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'In Progress',
                  value: '2,850',
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
                  value: '42,180',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '48,450',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'By Status',
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
                child: _buildStatusTag('Open', 3420, Colors.orange),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatusTag('Assigned', 2850, Colors.blue),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatusTag('Closed', 42180, Colors.green),
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
                child: _buildPriorityTag('High', 1250, Colors.red),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPriorityTag('Medium', 2850, Colors.orange),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPriorityTag('Low', 2170, Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status, int count, Color color) {
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
              fontSize: AppFontSizes.base,
              fontWeight: AppFontWeights.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
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
              fontSize: AppFontSizes.base,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAllOfficesOverview(bool isDark) {
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
                'All Offices',
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
                  title: 'Regions',
                  value: '8',
                  icon: Icons.map,
                  color: Colors.indigo,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Circles',
                  value: '2',
                  icon: Icons.account_balance,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  title: 'Offices',
                  value: '34',
                  icon: Icons.domain,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const Spacer(),
            ],
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
                'System-wide Escalations',
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
                  title: 'Total Escalations',
                  value: '185',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  title: 'Pending Review',
                  value: '12',
                  icon: Icons.pending,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Escalations by Role',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRoleEscalationTag('From SE', 12, Colors.red),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleEscalationTag('From EE', 55, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleEscalationTag('From DyEE', 118, Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Critical Escalations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildEscalationItem(
            ticketId: '#5670',
            fromRole: 'SE',
            reason: 'Organization-wide policy decision required',
          ),
          const SizedBox(height: 8),
          _buildEscalationItem(
            ticketId: '#5665',
            fromRole: 'SE',
            reason: 'Strategic resource allocation needed',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleEscalationTag(String role, int count, Color color) {
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
              fontSize: AppFontSizes.base,
              fontWeight: AppFontWeights.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
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

  Widget _buildEscalationItem({
    required String ticketId,
    required String fromRole,
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
                  'From $fromRole',
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
