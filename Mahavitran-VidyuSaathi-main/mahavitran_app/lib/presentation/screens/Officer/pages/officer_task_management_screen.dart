import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';

class OfficerTaskManagementScreen extends StatelessWidget {
  const OfficerTaskManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Task Management'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Active Tasks',
              style: TextStyle(
                fontSize: AppFontSizes.xl,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
             const SizedBox(height: AppSpacing.sm),
            Text(
              'Tasks assigned to team members will appear here',
              style: TextStyle(
                fontSize: AppFontSizes.sm,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
            ),
             const SizedBox(height: AppSpacing.xl),
             ElevatedButton(
               onPressed: (){},
               child: const Text('Assign New Task'),
             ),
          ],
        ),
      ),
    );
  }
}
