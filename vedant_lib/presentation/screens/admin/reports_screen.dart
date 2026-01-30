import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../provider/admin/analytics_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPriority = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        // Calculate report metrics
        final totalComplaints = analyticsProvider.complaints.length;
        final criticalComplaints = analyticsProvider.complaints.where((c) => c.priority == 'Critical').length;
        final highPriorityComplaints = analyticsProvider.complaints.where((c) => c.priority == 'High').length;
        final resolvedComplaints = analyticsProvider.staffMembers.fold(0, (sum, s) => sum + s.resolvedComplaints);
        final avgResolutionTime = 3.5; // Mock data
        final totalEscalations = analyticsProvider.staffMembers.fold(0, (sum, s) => sum + s.escalations);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports & Analytics',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.lightPrimary,
                            fontWeight: AppFontWeights.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Comprehensive overview of complaint statistics',
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
                          const SnackBar(content: Text('Generating PDF report...')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Filter Panel
                _buildFilterPanel(context, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Key Metrics Cards
                _buildMetricsSection(
                  context,
                  totalComplaints,
                  criticalComplaints,
                  highPriorityComplaints,
                  resolvedComplaints,
                  avgResolutionTime,
                  totalEscalations,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Charts Row
                _buildChartsSection(context, analyticsProvider, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Priority Distribution
                _buildPriorityDistribution(context, analyticsProvider, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Staff Performance Summary
                _buildStaffPerformanceSummary(context, analyticsProvider, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Recent Activity Log
                _buildRecentActivityLog(context, analyticsProvider, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPanel(BuildContext context, bool isDark) {
    return Container(
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
            'Filters',
            style: TextStyle(
              fontSize: AppFontSizes.base,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              // Date Range
              _buildDateSelector('Start Date', _startDate, (date) {
                setState(() => _startDate = date);
              }),
              _buildDateSelector('End Date', _endDate, (date) {
                setState(() => _endDate = date);
              }),
              // Priority Filter
              _buildDropdownFilter(
                'Priority',
                _selectedPriority,
                ['All', 'Critical', 'High', 'Medium', 'Low'],
                (value) => setState(() => _selectedPriority = value!),
                isDark,
              ),
              // Status Filter
              _buildDropdownFilter(
                'Status',
                _selectedStatus,
                ['All', 'Pending', 'In Progress', 'Resolved', 'Escalated'],
                (value) => setState(() => _selectedStatus = value!),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedPriority = 'All';
                    _selectedStatus = 'All';
                  });
                },
                child: const Text('Reset'),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filters applied')),
                  );
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime?) onChanged) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select',
              style: const TextStyle(fontSize: AppFontSizes.sm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    int totalComplaints,
    int criticalComplaints,
    int highPriorityComplaints,
    int resolvedComplaints,
    double avgResolutionTime,
    int totalEscalations,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: AppFontWeights.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'Total Complaints',
              totalComplaints.toString(),
              Icons.description,
              AppColors.statusInfo,
              '+12% from last month',
              isDark,
            ),
            _buildMetricCard(
              'Critical Issues',
              criticalComplaints.toString(),
              Icons.error,
              AppColors.statusCritical,
              'Requires immediate attention',
              isDark,
            ),
            _buildMetricCard(
              'Resolved',
              resolvedComplaints.toString(),
              Icons.check_circle,
              AppColors.statusNormal,
              '${((resolvedComplaints / (totalComplaints + resolvedComplaints)) * 100).toStringAsFixed(1)}% resolution rate',
              isDark,
            ),
            _buildMetricCard(
              'Avg. Resolution',
              '${avgResolutionTime.toStringAsFixed(1)} days',
              Icons.timer,
              AppColors.chart2Light,
              '-0.5 days from last month',
              isDark,
            ),
            _buildMetricCard(
              'High Priority',
              highPriorityComplaints.toString(),
              Icons.priority_high,
              const Color(0xFFEA580C),
              'Need quick action',
              isDark,
            ),
            _buildMetricCard(
              'Escalations',
              totalEscalations.toString(),
              Icons.warning,
              AppColors.statusOverloaded,
              'Due to delays',
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
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
            blurRadius: 4,
            offset: const Offset(0, 2),
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
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
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, AnalyticsProvider provider, bool isDark) {
    return Container(
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
            'Complaints Trend (Last 7 Days)',
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
    );
  }

  Widget _buildTrendBar(String label, int value, int maxValue, Color color, bool isDark) {
    final heightRatio = (value / maxValue).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: AppFontSizes.xs,
            fontWeight: AppFontWeights.medium,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 36,
          height: 150 * heightRatio,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color, color.withOpacity(0.6)],
            ),
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

  Widget _buildPriorityDistribution(BuildContext context, AnalyticsProvider provider, bool isDark) {
    final complaints = provider.complaints;
    final critical = complaints.where((c) => c.priority == 'Critical').length;
    final high = complaints.where((c) => c.priority == 'High').length;
    final medium = complaints.where((c) => c.priority == 'Medium').length;
    final low = complaints.where((c) => c.priority == 'Low').length;
    final total = complaints.length;

    return Container(
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
            'Priority Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPriorityBar('Critical', critical, total, AppColors.statusCritical, isDark),
          const SizedBox(height: AppSpacing.md),
          _buildPriorityBar('High', high, total, const Color(0xFFEA580C), isDark),
          const SizedBox(height: AppSpacing.md),
          _buildPriorityBar('Medium', medium, total, AppColors.statusOverloaded, isDark),
          const SizedBox(height: AppSpacing.md),
          _buildPriorityBar('Low', low, total, AppColors.statusInfo, isDark),
        ],
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color, bool isDark) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    return Column(
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
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: AppFontSizes.sm,
                fontWeight: AppFontWeights.medium,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStaffPerformanceSummary(BuildContext context, AnalyticsProvider provider, bool isDark) {
    final sortedStaff = List.from(provider.staffMembers)
      ..sort((a, b) => b.resolvedComplaints.compareTo(a.resolvedComplaints));
    final topPerformers = sortedStaff.take(3).toList();

    return Container(
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
            'Top Performers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...topPerformers.asMap().entries.map((entry) {
            final index = entry.key;
            final staff = entry.value;
            final medals = ['🥇', '🥈', '🥉'];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Text(medals[index], style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                    child: Text(
                      staff.name[0],
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
                            fontWeight: AppFontWeights.semiBold,
                            fontSize: AppFontSizes.sm,
                          ),
                        ),
                        Text(
                          staff.role,
                          style: TextStyle(
                            fontSize: AppFontSizes.xs,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${staff.resolvedComplaints}',
                        style: const TextStyle(
                          fontWeight: AppFontWeights.bold,
                          fontSize: AppFontSizes.lg,
                          color: AppColors.statusNormal,
                        ),
                      ),
                      Text(
                        'resolved',
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivityLog(BuildContext context, AnalyticsProvider provider, bool isDark) {
    final activities = [
      {'action': 'Complaint C2024-008 escalated', 'time': '2 hours ago', 'type': 'escalation'},
      {'action': 'Priya Sharma resolved C2024-003', 'time': '4 hours ago', 'type': 'resolved'},
      {'action': 'New complaint C2024-009 registered', 'time': '5 hours ago', 'type': 'new'},
      {'action': 'C2024-005 reassigned to Vikram Joshi', 'time': '6 hours ago', 'type': 'reassigned'},
      {'action': 'Amit Deshmukh resolved C2024-001', 'time': '8 hours ago', 'type': 'resolved'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeights.semiBold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...activities.map((activity) {
            IconData icon;
            Color color;
            switch (activity['type']) {
              case 'escalation':
                icon = Icons.warning;
                color = AppColors.statusOverloaded;
                break;
              case 'resolved':
                icon = Icons.check_circle;
                color = AppColors.statusNormal;
                break;
              case 'new':
                icon = Icons.add_circle;
                color = AppColors.statusInfo;
                break;
              case 'reassigned':
                icon = Icons.swap_horiz;
                color = AppColors.chart2Light;
                break;
              default:
                icon = Icons.info;
                color = AppColors.lightMuted;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['action']!,
                          style: TextStyle(
                            fontSize: AppFontSizes.sm,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        Text(
                          activity['time']!,
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
          }),
        ],
      ),
    );
  }
}
