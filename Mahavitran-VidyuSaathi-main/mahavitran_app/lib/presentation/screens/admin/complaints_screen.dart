import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../../domain/models/admin/complaint.dart';
import '../../../data/services/admin/mock_data_service.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool _isRefreshing = false;

  // Get all complaints from mock data
  List<Complaint> get complaints => MockDataService.activeAssignments;

  int get totalComplaints => complaints.length;
  int get pendingComplaints => complaints.where((c) => c.pendingDays > 0).length;
  int get criticalComplaints => complaints.where((c) => c.priority == 'Critical').length;

  void _handleRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  void _showComplaintDetails(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComplaintDetailsModal(complaint: complaint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        _handleRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title and Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Complaints',
                      style: TextStyle(
                        fontSize: AppFontSizes.xl,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 80,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.statusInfo,
                        borderRadius: const BorderRadius.all(Radius.circular(1)),
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _handleRefresh,
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Complaints',
                    value: totalComplaints.toString(),
                    icon: Icons.description_outlined,
                    color: AppColors.statusInfo,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Pending',
                    value: pendingComplaints.toString(),
                    icon: Icons.access_time,
                    color: AppColors.statusOverloaded,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Critical',
                    value: criticalComplaints.toString(),
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.statusCritical,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Complaints List
            ComplaintsList(
              complaints: complaints,
              onComplaintClick: _showComplaintDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.xxxl,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// Complaints List Widget
class ComplaintsList extends StatelessWidget {
  final List<Complaint> complaints;
  final Function(Complaint) onComplaintClick;

  const ComplaintsList({
    Key? key,
    required this.complaints,
    required this.onComplaintClick,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFFEF2F2);
      case 'High':
        return const Color(0xFFFFF7ED);
      case 'Medium':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaints List',
                  style: TextStyle(
                    fontSize: AppFontSizes.base,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 64,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.statusInfo,
                    borderRadius: const BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: complaints.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return InkWell(
                onTap: () => onComplaintClick(complaint),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            complaint.id,
                            style: TextStyle(
                              fontSize: AppFontSizes.sm,
                              fontWeight: AppFontWeights.medium,
                              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityBgColor(complaint.priority),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getPriorityColor(complaint.priority).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              complaint.priority,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: AppFontWeights.medium,
                                color: _getPriorityColor(complaint.priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Assigned to: ${complaint.assignedTo}',
                              style: TextStyle(
                                fontSize: AppFontSizes.sm,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                            ),
                          ),
                          Text(
                            '${complaint.pendingDays} days pending',
                            style: TextStyle(
                              fontSize: AppFontSizes.xs,
                              color: complaint.pendingDays > 5 ? AppColors.statusCritical : AppColors.statusOverloaded,
                              fontWeight: AppFontWeights.medium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Complaint Details Modal
class ComplaintDetailsModal extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsModal({Key? key, required this.complaint}) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFFEF2F2);
      case 'High':
        return const Color(0xFFFFF7ED);
      case 'Medium':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaint Details',
                          style: TextStyle(
                            fontSize: AppFontSizes.base,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.statusInfo,
                            borderRadius: const BorderRadius.all(Radius.circular(1)),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Complaint ID and Priority
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complaint ID',
                                style: TextStyle(
                                  fontSize: AppFontSizes.xs,
                                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                complaint.id,
                                style: TextStyle(
                                  fontSize: AppFontSizes.lg,
                                  fontWeight: AppFontWeights.semiBold,
                                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityBgColor(complaint.priority),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getPriorityColor(complaint.priority).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              complaint.priority,
                              style: TextStyle(
                                fontSize: AppFontSizes.xs,
                                fontWeight: AppFontWeights.medium,
                                color: _getPriorityColor(complaint.priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Assignment Information
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned To',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  complaint.assignedTo,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.sm,
                                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Pending Days
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pending Days',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${complaint.pendingDays} days',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.sm,
                                    color: complaint.pendingDays > 5
                                        ? AppColors.statusCritical
                                        : complaint.pendingDays > 3
                                            ? AppColors.statusOverloaded
                                            : AppColors.statusNormal,
                                    fontWeight: AppFontWeights.medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Status Indicator
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: complaint.pendingDays > 5
                              ? AppColors.statusCritical.withOpacity(0.1)
                              : complaint.pendingDays > 3
                                  ? AppColors.statusOverloaded.withOpacity(0.1)
                                  : AppColors.statusNormal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: complaint.pendingDays > 5
                                ? AppColors.statusCritical.withOpacity(0.3)
                                : complaint.pendingDays > 3
                                    ? AppColors.statusOverloaded.withOpacity(0.3)
                                    : AppColors.statusNormal.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              complaint.pendingDays > 5
                                  ? Icons.error_outline
                                  : complaint.pendingDays > 3
                                      ? Icons.warning
                                      : Icons.check_circle,
                              color: complaint.pendingDays > 5
                                  ? AppColors.statusCritical
                                  : complaint.pendingDays > 3
                                      ? AppColors.statusOverloaded
                                      : AppColors.statusNormal,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                complaint.pendingDays > 5
                                    ? 'Urgent attention required'
                                    : complaint.pendingDays > 3
                                        ? 'Needs attention soon'
                                        : 'Normal processing',
                                style: TextStyle(
                                  fontSize: AppFontSizes.sm,
                                  color: complaint.pendingDays > 5
                                      ? AppColors.statusCritical
                                      : complaint.pendingDays > 3
                                          ? AppColors.statusOverloaded
                                          : AppColors.statusNormal,
                                  fontWeight: AppFontWeights.medium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Divider and Customer Information
                      Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          fontWeight: AppFontWeights.medium,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoRow(Icons.person_outline, 'Customer Name', 'John Doe', isDark),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(Icons.phone_outlined, 'Contact', '+91 98765 43210', isDark),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(Icons.email_outlined, 'Email', 'john.doe@email.com', isDark),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(Icons.location_on_outlined, 'Location', 'Mumbai, Maharashtra', isDark),

                      const SizedBox(height: AppSpacing.xl),
                      Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      const SizedBox(height: AppSpacing.lg),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              side: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Close'),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton(
                            onPressed: () {
                              // Handle complaint resolution
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Complaint marked as resolved')),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusNormal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Mark as Resolved'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSizes.xs,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
