import 'package:flutter/material.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 60, color: Color(0xFF1976D2)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Officer Name',
                    style: TextStyle(
                      fontSize: AppFontSizes.xl,
                      fontWeight: AppFontWeights.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Senior Engineer', // Dynamic Role
                    style: TextStyle(
                      fontSize: AppFontSizes.sm,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: AppSpacing.xl),

             // Profile Details
             Container(
               padding: const EdgeInsets.all(AppSpacing.lg),
               decoration: BoxDecoration(
                 color: isDark ? AppColors.darkCard : AppColors.lightCard,
                 borderRadius: BorderRadius.circular(AppRadius.lg),
                 border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
               ),
               child: Column(
                 children: [
                   _buildProfileItem(Icons.email, 'Email', 'officer@mahavitran.in', isDark),
                   const Divider(),
                   _buildProfileItem(Icons.phone, 'Phone', '+91 9876543210', isDark),
                   const Divider(),
                   _buildProfileItem(Icons.badge, 'Employee ID', 'EMP10234', isDark),
                   const Divider(),
                   _buildProfileItem(Icons.location_city, 'Office', 'Circle Office, Pune', isDark),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
           const SizedBox(width: AppSpacing.lg),
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
                     fontSize: AppFontSizes.base,
                     color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }
}
