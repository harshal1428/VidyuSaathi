import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../../domain/models/admin/complaint.dart';
import '../../provider/admin/analytics_provider.dart';
import '../../widgets/admin/common/custom_button.dart';
import '../../widgets/admin/common/custom_card.dart';

class ReassignDialog extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback onClose;

  const ReassignDialog({
    Key? key,
    required this.complaint,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ReassignDialog> createState() => _ReassignDialogState();
}

class _ReassignDialogState extends State<ReassignDialog> {
  late String _selectedStaff;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStaff = '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsProvider = context.read<AnalyticsProvider>();
    final staffList = analyticsProvider.staffMembers;

    // Filter out currently assigned staff
    final availableStaff =
        staffList.where((s) => s.name != widget.complaint.assignedTo).toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                    'Reassign Complaint',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint ID
                  _buildInfoSection(
                    label: 'Complaint ID',
                    value: widget.complaint.id,
                    context: context,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Currently Assigned To
                  _buildInfoSection(
                    label: 'Currently Assigned To',
                    value: widget.complaint.assignedTo,
                    context: context,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Reassign To Dropdown
                  Text(
                    'Reassign To',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: _selectedStaff.isEmpty ? null : _selectedStaff,
                      hint: const Text('Select staff member...'),
                      items: availableStaff.map((staff) {
                        return DropdownMenuItem(
                          value: staff.name,
                          child: Text('${staff.name} - ${staff.role}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStaff = value ?? '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Priority and Pending Days Info
                  CustomCard(
                    backgroundColor: AppColors.statusOverloaded.withOpacity(0.1),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Priority',
                                style: TextStyle(
                                  fontSize: AppFontSizes.sm,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.complaint.priority,
                                style: const TextStyle(
                                  fontWeight: AppFontWeights.semiBold,
                                  fontSize: AppFontSizes.base,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending Days',
                                style: TextStyle(
                                  fontSize: AppFontSizes.sm,
                                  color: isDark
                                      ? AppColors.darkMutedForeground
                                      : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${widget.complaint.pendingDays} days',
                                style: const TextStyle(
                                  fontWeight: AppFontWeights.semiBold,
                                  fontSize: AppFontSizes.base,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        label: 'Cancel',
                        isOutlined: true,
                        onPressed: widget.onClose,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      CustomButton(
                        label: 'Reassign',
                        isLoading: _isLoading,
                        onPressed: _selectedStaff.isEmpty
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                // Simulate API call
                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                                context.read<AnalyticsProvider>().reassignComplaint(
                                      widget.complaint.id,
                                      _selectedStaff,
                                    );
                                setState(() => _isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Complaint reassigned to $_selectedStaff',
                                      ),
                                    ),
                                  );
                                  widget.onClose();
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
        ),
      ],
    );
  }
}
