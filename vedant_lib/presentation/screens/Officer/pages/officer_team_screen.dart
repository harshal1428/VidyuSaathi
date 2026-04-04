import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';
import 'package:civic_core/domain/models/admin/staff_member.dart';
import 'package:civic_core/data/services/admin/mock_data_service.dart';
import 'package:civic_core/presentation/widgets/admin/common/status_badge.dart'; // Reusing admin widget for consistency
import 'officer_profile_screen.dart'; // Placeholder for viewing staff profile

class OfficerTeamScreen extends StatefulWidget {
  const OfficerTeamScreen({Key? key}) : super(key: key);

  @override
  State<OfficerTeamScreen> createState() => _OfficerTeamScreenState();
}

class _OfficerTeamScreenState extends State<OfficerTeamScreen> {
  // Mock data for team. In real app, filter by reporting officer
  List<StaffMember> get teamMembers => MockDataService.staffData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Team'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Summary Section
            _buildTeamSummary(context, isDark),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Team Members',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teamMembers.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                return _buildStaffCard(context, teamMembers[index], isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSummary(BuildContext context, bool isDark) {
    final totalStaff = teamMembers.length;
    final activeStaff = teamMembers.where((s) => s.status == 'Active').length;
    final overloadedStaff = teamMembers.where((s) => s.status == 'Overloaded').length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(totalStaff.toString(), 'Total Staff', isDark),
          _buildSummaryItem(activeStaff.toString(), 'Active', isDark, color: AppColors.statusNormal),
          _buildSummaryItem(overloadedStaff.toString(), 'Overloaded', isDark, color: AppColors.statusOverloaded),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, bool isDark, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.xxxl,
            fontWeight: AppFontWeights.bold,
            color: color ?? (isDark ? AppColors.darkForeground : AppColors.lightForeground),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffMember staff, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      staff.role,
                      style: TextStyle(
                        fontSize: AppFontSizes.xs,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
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
          Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: AppSpacing.md),
          
          // Workload Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkloadStat('Active', staff.activeComplaints.toString(), AppColors.statusInfo, isDark),
              _buildWorkloadStat('Resolved', staff.resolvedComplaints.toString(), AppColors.statusNormal, isDark),
              _buildWorkloadStat('Escalations', staff.escalations.toString(), AppColors.statusOverloaded, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadStat(String label, String value, Color color, bool isDark) {
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
          style: TextStyle(
            fontSize: AppFontSizes.xs,
            fontWeight: AppFontWeights.medium,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }
}
