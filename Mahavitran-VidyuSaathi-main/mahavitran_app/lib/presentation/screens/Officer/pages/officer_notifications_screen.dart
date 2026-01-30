import 'package:flutter/material.dart';
import 'package:mahavitran_app/presentation/constants/app_colors.dart';

class OfficerNotificationsScreen extends StatelessWidget {
  const OfficerNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      {
        'title': 'New Incident Assigned',
        'message': 'Ticket #C2024-009 has been assigned to your team.',
        'time': '10 mins ago',
        'isRead': false,
      },
      {
        'title': 'High Priority Alert',
        'message': 'Voltage fluctuation reported in Sector 4 substation.',
        'time': '1 hour ago',
        'isRead': false,
      },
      {
        'title': 'System Maintenance',
        'message': 'Scheduled server maintenance tonight from 2 AM to 4 AM.',
        'time': '5 hours ago',
        'isRead': true,
      },
       {
        'title': 'Task Completed',
        'message': 'Engineer Vikram Joshi marked Ticket #C2024-005 as resolved.',
        'time': 'Yesterday',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead = notification['isRead'] as bool;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark 
                  ? (isRead ? AppColors.darkCard : AppColors.darkCard.withOpacity(0.8)) 
                  : (isRead ? AppColors.lightCard : Colors.blue.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                if (!isRead)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AppColors.darkForeground : AppColors.lightPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: TextStyle(
                                fontSize: AppFontSizes.base,
                                fontWeight: isRead ? AppFontWeights.medium : AppFontWeights.bold,
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground.withOpacity(0.7) : AppColors.lightMutedForeground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
