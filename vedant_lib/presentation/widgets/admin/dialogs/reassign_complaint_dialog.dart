import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../../domain/models/admin/complaint.dart';
import '../common/app_button.dart';
import '../common/status_badge.dart';

class ReassignComplaintDialog extends StatefulWidget {
  final Complaint complaint;
  final List<String> staffList;
  final VoidCallback onClose;
  final Function(String complaintId, String newStaff) onReassign;

  const ReassignComplaintDialog({
    Key? key,
    required this.complaint,
    required this.staffList,
    required this.onClose,
    required this.onReassign,
  }) : super(key: key);

  @override
  State<ReassignComplaintDialog> createState() => _ReassignComplaintDialogState();
}

class _ReassignComplaintDialogState extends State<ReassignComplaintDialog> {
  String? selectedStaff;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final availableStaff = widget.staffList
        .where((staff) => staff != widget.complaint.assignedTo)
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reassign Complaint',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(
                      Icons.close,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
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
                  Text(
                    'Complaint ID',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.complaint.id,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Currently Assigned To
                  Text(
                    'Currently Assigned To',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.complaint.assignedTo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFontWeights.medium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Reassign To
                  Text(
                    'Reassign To',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: selectedStaff,
                    items: availableStaff.map((staff) {
                      return DropdownMenuItem<String>(
                        value: staff,
                        child: Text(staff),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStaff = value;
                      });
                    },
                    hint: const Text('Select staff member...'),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Priority and Pending Days
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Priority: ${widget.complaint.priority}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF78350F),
                            fontWeight: AppFontWeights.medium,
                          ),
                        ),
                        Text(
                          'Pending: ${widget.complaint.pendingDays} days',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF78350F),
                            fontWeight: AppFontWeights.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onClose,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: selectedStaff != null
                        ? () {
                            widget.onReassign(widget.complaint.id, selectedStaff!);
                            widget.onClose();
                          }
                        : null,
                    child: const Text('Reassign'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
