import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../../domain/models/admin/staff_member.dart';
import '../../widgets/admin/common/custom_button.dart';
import '../../widgets/admin/common/custom_card.dart';

class StaffDetailPanel extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onClose;

  const StaffDetailPanel({
    Key? key,
    required this.staff,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Staff Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    Row(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Center(
                            child: Text(
                              staff.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: AppFontWeights.bold,
                                fontSize: AppFontSizes.xxxl,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                staff.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                staff.role,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      staff.email,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Performance Stats
                    Text(
                      'Performance Overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            backgroundColor: AppColors.statusInfo.withOpacity(0.1),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: 16,
                                      color: AppColors.statusInfo,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.sm,
                                        color: isDark
                                            ? AppColors.darkMutedForeground
                                            : AppColors.lightMutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  staff.activeComplaints.toString(),
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.xxl,
                                    fontWeight: AppFontWeights.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: CustomCard(
                            backgroundColor: AppColors.statusNormal.withOpacity(0.1),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppColors.statusNormal,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Resolved',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.sm,
                                        color: isDark
                                            ? AppColors.darkMutedForeground
                                            : AppColors.lightMutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  staff.resolvedComplaints.toString(),
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.xxl,
                                    fontWeight: AppFontWeights.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: CustomCard(
                            backgroundColor: AppColors.statusOverloaded.withOpacity(0.1),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 16,
                                      color: AppColors.statusOverloaded,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Escalations',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.sm,
                                        color: isDark
                                            ? AppColors.darkMutedForeground
                                            : AppColors.lightMutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  staff.escalations.toString(),
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.xxl,
                                    fontWeight: AppFontWeights.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Resolution Performance
                    Text(
                      'Resolution Performance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    _buildPerformanceRow(
                      label: 'Resolution Rate',
                      value: '${((staff.resolvedComplaints / (staff.activeComplaints + staff.resolvedComplaints)) * 100).toStringAsFixed(1)}%',
                      isDark: isDark,
                    ),
                    _buildPerformanceRow(
                      label: 'Escalation Rate',
                      value: '${((staff.escalations / (staff.activeComplaints + staff.resolvedComplaints)) * 100).toStringAsFixed(1)}%',
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          label: 'Close',
                          isOutlined: true,
                          onPressed: onClose,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        CustomButton(
                          label: 'View Full Details',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View full details coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: AppFontWeights.semiBold,
              fontSize: AppFontSizes.lg,
            ),
          ),
        ],
      ),
    );
  }
}
