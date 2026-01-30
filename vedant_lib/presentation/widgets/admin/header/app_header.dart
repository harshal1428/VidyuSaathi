import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../common/status_badge.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final int notificationCount;

  const AppHeader({
    Key? key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      elevation: 1,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      foregroundColor: isDark ? AppColors.darkForeground : AppColors.lightForeground,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: GestureDetector(
          onTap: onMenuPressed,
          child: const Icon(Icons.menu),
        ),
      ),
      title: const Text('Mahavitaran Admin'),
      titleSpacing: 0,
      actions: [
        // Notification Button
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: GestureDetector(
            onTap: onNotificationPressed,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_none,
                    size: 24,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: 8,
                    right: 0,
                    child: NotificationBadge(
                      count: notificationCount,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Profile Section
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Admin User',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: AppFontWeights.medium,
                    ),
                  ),
                  Text(
                    'Regional Admin',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onProfilePressed,
                child: Icon(
                  Icons.expand_more,
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
