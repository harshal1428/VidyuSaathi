import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';

class OfficerEscalationsScreen extends StatelessWidget {
  const OfficerEscalationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Escalations'),
        elevation: 0,
        backgroundColor: Colors.red, // Distinct color for escalations
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Critical Escalations',
              style: TextStyle(
                fontSize: AppFontSizes.xl,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
