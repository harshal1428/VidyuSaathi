import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../../domain/models/admin/staff_member.dart';
import '../../../domain/models/admin/complaint.dart';
import '../../provider/admin/analytics_provider.dart';
import '../../widgets/admin/common/custom_input_field.dart';
import '../../widgets/admin/common/status_badge.dart';
import 'staff_detail_panel.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late TextEditingController _searchController;
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        final filteredStaff = analyticsProvider.getFilteredStaff();
        final roles = analyticsProvider.getUniqueRoles();
        
        // Calculate metrics
        final totalStaff = analyticsProvider.staffMembers.length;
        final totalActiveAssignments = analyticsProvider.staffMembers
            .fold(0, (sum, staff) => sum + staff.activeComplaints);
        final totalEscalations = analyticsProvider.staffMembers
            .fold(0, (sum, staff) => sum + staff.escalations);
        final escalationsLast7Days = analyticsProvider.escalationData
            .fold(0, (sum, day) => sum + (day['escalations'] as int? ?? 0));

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Management',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Monitor staff workload, assignments, and escalations',
                          style: TextStyle(
                            fontSize: AppFontSizes.sm,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      analyticsProvider.setSearchQuery('');
                      analyticsProvider.setRoleFilter('All');
                      _searchController.clear();
                      setState(() => _selectedRole = 'All');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data refreshed')),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Key Metrics Row
              _buildMetricsGrid(
                context,
                totalStaff,
                totalActiveAssignments,
                totalEscalations,
                escalationsLast7Days,
                isDark,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Staff Workload Section
              _buildStaffWorkloadSection(context, analyticsProvider, filteredStaff, roles, isDark),
              const SizedBox(height: AppSpacing.xl),

              // Active Assignments Section
              _buildActiveAssignmentsSection(context, analyticsProvider, isDark),
              const SizedBox(height: AppSpacing.xl),

              // Escalation Statistics Section
              _buildEscalationStatisticsSection(
                context,
                analyticsProvider,
                totalEscalations,
                escalationsLast7Days,
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    int totalStaff,
    int totalActiveAssignments,
    int totalEscalations,
    int escalationsLast7Days,
    bool isDark,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMetricCard(
            context: context,
            title: 'Total Staff',
            value: totalStaff.toString(),
            subtitle: 'Officers and Field Officers',
            icon: Icons.people,
            color: AppColors.chart1Light,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.md),
          _buildMetricCard(
            context: context,
            title: 'Active Assignments',
            value: totalActiveAssignments.toString(),
            subtitle: 'Currently assigned complaints',
            icon: Icons.assignment,
            color: AppColors.statusInfo,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.md),
          _buildMetricCard(
            context: context,
            title: 'Escalations by Staff',
            value: totalEscalations.toString(),
            subtitle: 'Due to staff delay',
            icon: Icons.warning,
            color: AppColors.statusOverloaded,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.md),
          _buildMetricCard(
            context: context,
            title: 'Last 7 Days',
            value: escalationsLast7Days.toString(),
            subtitle: 'Escalations',
            icon: Icons.trending_up,
            color: AppColors.chart2Light,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 180,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
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
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffWorkloadSection(
    BuildContext context,
    AnalyticsProvider analyticsProvider,
    List<StaffMember> filteredStaff,
    List<String> roles,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Workload',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'View officer workload and performance',
                    style: TextStyle(
                      fontSize: AppFontSizes.sm,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Search and Filter Row
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  hint: 'Search by name or email...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    analyticsProvider.setSearchQuery(value);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    items: roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                        analyticsProvider.setRoleFilter(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Staff List
          filteredStaff.isEmpty
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 48,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No staff members found',
                        style: TextStyle(
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredStaff.length,
                  itemBuilder: (context, index) {
                    final staff = filteredStaff[index];
                    return _buildStaffCard(context, staff, isDark);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffMember staff, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0] : '',
                  style: const TextStyle(
                    color: AppColors.lightPrimary,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      style: const TextStyle(
                        fontWeight: AppFontWeights.bold,
                        fontSize: AppFontSizes.sm,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      staff.email,
                      style: TextStyle(
                        fontSize: AppFontSizes.xs,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: staff.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Workload Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkloadStat('Active', staff.activeComplaints.toString(), AppColors.statusInfo),
              _buildWorkloadStat('Resolved', staff.resolvedComplaints.toString(), AppColors.statusNormal),
              _buildWorkloadStat('Escalations', staff.escalations.toString(), AppColors.statusOverloaded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Workload Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workload',
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                  Text(
                    '${staff.activeComplaints} active',
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      fontWeight: AppFontWeights.medium,
                      color: staff.status == 'Overloaded' ? AppColors.statusOverloaded : AppColors.statusNormal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: LinearProgressIndicator(
                  value: (staff.activeComplaints / 20).clamp(0.0, 1.0),
                  backgroundColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    staff.status == 'Overloaded' ? AppColors.statusOverloaded : AppColors.statusNormal,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showStaffDetailPanel(context, staff);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.lg,
            fontWeight: AppFontWeights.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.xs,
            fontWeight: AppFontWeights.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAssignmentsSection(
    BuildContext context,
    AnalyticsProvider analyticsProvider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Assignments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Current complaint assignments to staff',
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analyticsProvider.complaints.length,
            itemBuilder: (context, index) {
              final complaint = analyticsProvider.complaints[index];
              return _buildAssignmentCard(context, complaint, analyticsProvider, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    Complaint complaint,
    AnalyticsProvider analyticsProvider,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                complaint.id,
                style: const TextStyle(
                  fontWeight: AppFontWeights.bold,
                  fontSize: AppFontSizes.sm,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(complaint.priority),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  complaint.priority,
                  style: const TextStyle(
                    fontSize: AppFontSizes.xs,
                    color: Colors.white,
                    fontWeight: AppFontWeights.medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Assigned to: ${complaint.assignedTo}',
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: complaint.pendingDays > 5 ? AppColors.statusCritical : AppColors.statusOverloaded,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Pending: ${complaint.pendingDays} days',
                style: TextStyle(
                  fontSize: AppFontSizes.xs,
                  color: complaint.pendingDays > 5 ? AppColors.statusCritical : AppColors.statusOverloaded,
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  _showReassignModal(context, complaint, analyticsProvider);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: const Text('Reassign'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationStatisticsSection(
    BuildContext context,
    AnalyticsProvider analyticsProvider,
    int totalEscalations,
    int escalationsLast7Days,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escalation Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Complaints escalated in last 7 days',
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.statusOverloaded.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.statusOverloaded, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Total Escalations',
                              style: TextStyle(
                                fontSize: AppFontSizes.sm,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        totalEscalations.toString(),
                        style: const TextStyle(
                          fontSize: AppFontSizes.xxxl,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.chart2Light.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: AppColors.chart2Light, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Last 7 Days',
                              style: TextStyle(
                                fontSize: AppFontSizes.sm,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        escalationsLast7Days.toString(),
                        style: const TextStyle(
                          fontSize: AppFontSizes.xxxl,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Escalation Chart (simplified bar representation)
          Text(
            'Daily Escalations',
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              fontWeight: AppFontWeights.medium,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: analyticsProvider.escalationData.map((data) {
                final escalations = data['escalations'] as int? ?? 0;
                final maxEscalations = 10;
                final heightRatio = (escalations / maxEscalations).clamp(0.1, 1.0);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      escalations.toString(),
                      style: TextStyle(
                        fontSize: AppFontSizes.xs,
                        fontWeight: AppFontWeights.medium,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 32,
                      height: 80 * heightRatio,
                      decoration: BoxDecoration(
                        color: AppColors.statusOverloaded,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      data['day'] as String? ?? '',
                      style: TextStyle(
                        fontSize: AppFontSizes.xs,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return AppColors.statusCritical;
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return AppColors.statusOverloaded;
      default:
        return AppColors.statusInfo;
    }
  }

  void _showStaffDetailPanel(BuildContext context, StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => StaffDetailPanel(
        staff: staff,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showReassignModal(
    BuildContext context,
    Complaint complaint,
    AnalyticsProvider analyticsProvider,
  ) {
    String? selectedStaff;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Reassign ${complaint.id}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current assignee: ${complaint.assignedTo}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select new assignee',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedStaff,
                  items: analyticsProvider.staffMembers
                      .where((s) => s.name != complaint.assignedTo)
                      .map((staff) => DropdownMenuItem(
                            value: staff.name,
                            child: Text(staff.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStaff = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedStaff == null
                    ? null
                    : () {
                        analyticsProvider.reassignComplaint(complaint.id, selectedStaff!);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${complaint.id} reassigned to $selectedStaff'),
                          ),
                        );
                      },
                child: const Text('Reassign'),
              ),
            ],
          );
        },
      ),
    );
  }
}
