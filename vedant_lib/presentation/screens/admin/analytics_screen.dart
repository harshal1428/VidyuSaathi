import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String priority = 'all';
  String status = 'all';

  void _resetFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      priority = 'all';
      status = 'all';
    });
  }

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters applied successfully')),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.lightPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.lightPrimary,
                    fontWeight: AppFontWeights.semiBold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFilterPanel(isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildMetricCards(isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildChartsRow1(isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildChartsRow2(isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildComplaintHistoryTable(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildDateRangePicker(isDark)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _buildPriorityDropdown(isDark)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _buildStatusDropdown(isDark)),
                    const SizedBox(width: AppSpacing.lg),
                    _buildActionButtons(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDateRangePicker(isDark),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPriorityDropdown(isDark),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStatusDropdown(isDark),
                    const SizedBox(height: AppSpacing.lg),
                    _buildActionButtons(),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildDateRangePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                context,
                startDate,
                'Start date',
                true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'to',
                style: TextStyle(
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            ),
            Expanded(
              child: _buildDateButton(
                context,
                endDate,
                'End date',
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    DateTime? date,
    String label,
    bool isStartDate,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _selectDate(context, isStartDate),
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        date != null ? DateFormat('MMM dd, yyyy').format(date) : label,
        style: const TextStyle(fontSize: AppFontSizes.sm),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildPriorityDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complaint Priority',
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: priority,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => setState(() => priority = value!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complaint Status',
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: status,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'open', child: Text('Open')),
                DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'escalated', child: Text('Escalated')),
              ],
              onChanged: (value) => setState(() => status = value!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          ),
          child: const Text('Apply'),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton(
          onPressed: _resetFilters,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildMetricCards(bool isDark) {
    Widget card(String title, String value, IconData icon, Color color, String change) {
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
                  title,
                  style: TextStyle(
                    fontSize: AppFontSizes.sm,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: AppFontWeights.semiBold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$change from last month',
              style: TextStyle(
                fontSize: AppFontSizes.xs,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        final children = [
          card('Total Complaints', '1,247', Icons.file_copy_outlined, AppColors.statusInfo, '+12.5%'),
          card('Resolved', '896', Icons.check_circle_outline, AppColors.statusNormal, '+8.2%'),
          card('Pending', '289', Icons.access_time, AppColors.statusOverloaded, '+3.1%'),
          card('Escalated', '62', Icons.error_outline, AppColors.statusCritical, '+5.4%'),
        ];

        if (wide) {
          return Row(
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: children[1]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: children[2]),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: children[3]),
            ],
          );
        }

        return Column(
          children: [
            children[0],
            const SizedBox(height: AppSpacing.lg),
            children[1],
            const SizedBox(height: AppSpacing.lg),
            children[2],
            const SizedBox(height: AppSpacing.lg),
            children[3],
          ],
        );
      },
    );
  }

  Widget _buildChartsRow1(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildLineChart(isDark)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _buildBarChart(isDark)),
                ],
              )
            : Column(
                children: [
                  _buildLineChart(isDark),
                  const SizedBox(height: AppSpacing.lg),
                  _buildBarChart(isDark),
                ],
              );
      },
    );
  }

  Widget _buildChartsRow2(bool isDark) {
    return _buildAreaChart(isDark);
  }

  Widget _buildLineChart(bool isDark) {
    return _chartCard(
      isDark: isDark,
      title: 'Monthly Complaint Registrations',
      subtitle: 'Trend of complaint registrations over time',
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) => FlLine(
                color: const Color(0xFFE5E7EB),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Text(
                        months[value.toInt()],
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 120),
                  FlSpot(1, 150),
                  FlSpot(2, 170),
                  FlSpot(3, 190),
                  FlSpot(4, 210),
                  FlSpot(5, 250),
                ],
                isCurved: true,
                color: AppColors.lightPrimary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.lightPrimary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    return _chartCard(
      isDark: isDark,
      title: 'Escalation Trends',
      subtitle: 'Complaints escalated by priority',
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 40,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) => FlLine(
                color: const Color(0xFFE5E7EB),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const labels = ['Low', 'Medium', 'High'];
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Text(
                        labels[value.toInt()],
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(toY: 12, color: AppColors.statusNormal, width: 30),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(toY: 28, color: AppColors.statusOverloaded, width: 30),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(toY: 35, color: AppColors.statusCritical, width: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart(bool isDark) {
    return _chartCard(
      isDark: isDark,
      title: 'Average Resolution Time',
      subtitle: 'Days taken to resolve complaints by month',
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 2,
              getDrawingHorizontalLine: (value) => FlLine(
                color: const Color(0xFFE5E7EB),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}d',
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Text(
                        months[value.toInt()],
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 8),
                  FlSpot(1, 7),
                  FlSpot(2, 5.5),
                  FlSpot(3, 6),
                  FlSpot(4, 5),
                  FlSpot(5, 4.5),
                ],
                isCurved: true,
                color: AppColors.chart3Light,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.chart3Light.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
            title,
            style: TextStyle(
              fontSize: AppFontSizes.base,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildComplaintHistoryTable(bool isDark) {
    final complaints = [
      ComplaintRecord('CMP-2024-1234', 'Jan 15, 2026', 'High', 'Resolved', 'Sarah Johnson', '2.5 days'),
      ComplaintRecord('CMP-2024-1235', 'Jan 14, 2026', 'Medium', 'In Progress', 'Michael Chen', '-'),
      ComplaintRecord('CMP-2024-1236', 'Jan 14, 2026', 'Low', 'Resolved', 'Emily Davis', '4.0 days'),
      ComplaintRecord('CMP-2024-1237', 'Jan 13, 2026', 'High', 'Escalated', 'Robert Martinez', '-'),
      ComplaintRecord('CMP-2024-1238', 'Jan 13, 2026', 'Medium', 'Resolved', 'Jennifer Lee', '3.2 days'),
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
          Text(
            'Complaint History',
            style: TextStyle(
              fontSize: AppFontSizes.base,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Historical complaint records and resolution details',
            style: TextStyle(
              fontSize: AppFontSizes.xs,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkMuted : const Color(0xFFF9FAFB),
              ),
              border: TableBorder.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1),
              columns: const [
                DataColumn(label: Text('Complaint ID', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Assigned Officer', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Resolution Time', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
              rows: complaints.map((complaint) {
                return DataRow(
                  cells: [
                    DataCell(Text(complaint.id, style: const TextStyle(fontSize: AppFontSizes.sm))),
                    DataCell(Text(complaint.date, style: const TextStyle(fontSize: AppFontSizes.sm))),
                    DataCell(_buildPriorityBadge(complaint.priority)),
                    DataCell(_buildStatusBadge(complaint.status)),
                    DataCell(Text(complaint.officer, style: const TextStyle(fontSize: AppFontSizes.sm))),
                    DataCell(Text(complaint.resolutionTime, style: const TextStyle(fontSize: AppFontSizes.sm))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color backgroundColor;
    Color textColor;

    switch (priority) {
      case 'High':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        break;
      case 'Medium':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFA16207);
        break;
      case 'Low':
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: backgroundColor.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        priority,
        style: TextStyle(fontSize: AppFontSizes.xs, color: textColor, fontWeight: AppFontWeights.medium),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Resolved':
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF166534);
        break;
      case 'In Progress':
        backgroundColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1E40AF);
        break;
      case 'Escalated':
        backgroundColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: backgroundColor.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: AppFontSizes.xs, color: textColor, fontWeight: AppFontWeights.medium),
      ),
    );
  }
}

class ComplaintRecord {
  final String id;
  final String date;
  final String priority;
  final String status;
  final String officer;
  final String resolutionTime;

  ComplaintRecord(this.id, this.date, this.priority, this.status, this.officer, this.resolutionTime);
}

