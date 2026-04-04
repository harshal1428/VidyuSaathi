import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_core/presentation/constants/app_colors.dart';
import 'package:civic_core/presentation/provider/admin/theme_provider.dart';

import 'package:civic_core/presentation/screens/Officer/pages/officer_notifications_screen.dart';
import 'package:civic_core/presentation/screens/Officer/pages/officer_help_screen.dart';

class OfficerSettingsScreen extends StatelessWidget {
  const OfficerSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
             Container(
               padding: const EdgeInsets.all(AppSpacing.lg),
               decoration: BoxDecoration(
                 color: isDark ? AppColors.darkCard : AppColors.lightCard,
                 borderRadius: BorderRadius.circular(AppRadius.lg),
                 border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
               ),
               child: Column(
                 children: [
                   // Dark Mode Toggle
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           Icon(Icons.dark_mode_outlined, color: isDark ? AppColors.darkForeground : AppColors.lightForeground),
                           const SizedBox(width: AppSpacing.md),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'Dark Mode',
                                 style: TextStyle(
                                   fontSize: AppFontSizes.base,
                                   fontWeight: AppFontWeights.medium,
                                   color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                 ),
                               ),
                               const SizedBox(height: 2),
                               Text(
                                 'Enable dark theme',
                                 style: TextStyle(
                                   fontSize: AppFontSizes.xs,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                       Consumer<ThemeProvider>(
                         builder: (context, provider, _) { // Reusing existing ThemeProvider
                           return Switch(
                             value: provider.isDarkMode,
                             onChanged: (value) {
                               provider.toggleTheme();
                             },
                           );
                         },
                       ),
                     ],
                   ),
                   const Divider(),
                   // Notifications
                   InkWell(
                     onTap: () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (context) => const OfficerNotificationsScreen()),
                         );
                     },
                     child: _buildSettingsRow(
                       Icons.notifications_outlined, 
                       'Notifications', 
                       'Manage push notifications', 
                       isDark,
                       trailing: const Icon(Icons.chevron_right),
                     ),
                   ),
                   const Divider(),
                   // Help & Support
                   InkWell(
                     onTap: () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (context) => const OfficerHelpScreen()),
                         );
                     },
                     child: _buildSettingsRow(
                       Icons.help_outline, 
                       'Help & Support', 
                       'FAQs and contact support', 
                       isDark,
                        trailing: const Icon(Icons.chevron_right),
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: AppSpacing.xl),
             OutlinedButton(
               onPressed: () {
                 // Logout logic here
               },
               style: OutlinedButton.styleFrom(
                 foregroundColor: Colors.red,
                 side: const BorderSide(color: Colors.red),
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 minimumSize: const Size(double.infinity, 50),
               ),
               child: const Text('Logout'),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, String subtitle, bool isDark, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isDark ? AppColors.darkForeground : AppColors.lightForeground),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.base,
                      fontWeight: AppFontWeights.medium,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
