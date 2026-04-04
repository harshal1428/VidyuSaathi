import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';
import 'package:civic_core/domain/models/admin/complaint.dart';
import 'package:civic_core/data/services/admin/mock_data_service.dart';

class OfficerAllTicketsScreen extends StatefulWidget {
  const OfficerAllTicketsScreen({Key? key}) : super(key: key);

  @override
  State<OfficerAllTicketsScreen> createState() => _OfficerAllTicketsScreenState();
}

class _OfficerAllTicketsScreenState extends State<OfficerAllTicketsScreen> {
  bool _isRefreshing = false;

  // Get all complaints from mock data (In real app, filter by Officer ID/Role)
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
      builder: (context) => _ComplaintDetailsModal(complaint: complaint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('All Tickets'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleRefresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total',
                      value: totalComplaints.toString(),
                      icon: Icons.description_outlined,
                      color: AppColors.statusInfo,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pending',
                      value: pendingComplaints.toString(),
                      icon: Icons.access_time,
                      color: AppColors.statusOverloaded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Critical',
                      value: criticalComplaints.toString(),
                      icon: Icons.warning_amber_outlined,
                      color: AppColors.statusCritical,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Complaints List
              _ComplaintsList(
                complaints: complaints,
                onComplaintClick: _showComplaintDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
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

class _ComplaintsList extends StatelessWidget {
  final List<Complaint> complaints;
  final Function(Complaint) onComplaintClick;

  const _ComplaintsList({
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

class _ComplaintDetailsModal extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintDetailsModal({Key? key, required this.complaint}) : super(key: key);

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
                          'Ticket Details',
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
                                'Ticket ID',
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

                      Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      const SizedBox(height: AppSpacing.lg),

                      // Action Buttons for Officer
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
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Close'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                           OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reassigning ticket...')),
                              );
                              Navigator.pop(context);
                            },
                             style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Reassign'),
                          ),
                           const SizedBox(width: AppSpacing.sm),
                           OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Escalating ticket...')),
                              );
                              Navigator.pop(context);
                            },
                             style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Escalate'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: () {
                               // Handle complaint resolution
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ticket marked as resolved')),
                              );
                              Navigator.pop(context);
                            },
                             style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusNormal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            ),
                            child: const Text('Resolve'),
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
