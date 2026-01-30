import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../common/role_switcher.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const MenuItem({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });
}

class AppSidebar extends StatelessWidget {
  final List<MenuItem> items;
  final bool isOpen;
  final VoidCallback? onClose;
  final Color? backgroundColor;

  const AppSidebar({
    Key? key,
    required this.items,
    this.isOpen = false,
    this.onClose,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final sidebarBgColor = backgroundColor ?? 
        (isDark ? AppColors.darkSidebar : AppColors.lightSidebar);

    return Drawer(
      backgroundColor: sidebarBgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSidebar : AppColors.lightSidebar,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkSidebarBorder : AppColors.lightSidebarBorder,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Mahavitaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: item.isActive
                    ? (isDark ? AppColors.darkSidebarPrimary : AppColors.lightSidebarPrimary).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: ListTile(
                leading: Icon(
                  item.icon,
                  color: item.isActive
                      ? (isDark ? AppColors.darkSidebarPrimary : AppColors.lightSidebarPrimary)
                      : (isDark ? AppColors.darkSidebarForeground : AppColors.lightSidebarForeground),
                ),
                title: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: item.isActive ? AppFontWeights.semiBold : AppFontWeights.normal,
                    color: item.isActive
                        ? (isDark ? AppColors.darkSidebarPrimary : AppColors.lightSidebarPrimary)
                        : (isDark ? AppColors.darkSidebarForeground : AppColors.lightSidebarForeground),
                  ),
                ),
                onTap: () {
                  item.onTap?.call();
                  onClose?.call();
                },
              ),
            );
          }),
          const Divider(),
          // Role Switcher for development/testing
          const RoleSwitcher(),
        ],
      ),
    );
  }
}

final appSidebarMenuItems = [
  const MenuItem(
    label: 'Dashboard',
    icon: Icons.dashboard,
    isActive: false,
  ),
  const MenuItem(
    label: 'Staff Management',
    icon: Icons.people,
    isActive: true,
  ),
  const MenuItem(
    label: 'Complaints',
    icon: Icons.description,
    isActive: false,
  ),
  const MenuItem(
    label: 'Escalations',
    icon: Icons.warning,
    isActive: false,
  ),
  const MenuItem(
    label: 'Reports',
    icon: Icons.bar_chart,
    isActive: false,
  ),
  const MenuItem(
    label: 'Settings',
    icon: Icons.settings,
    isActive: false,
  ),
];


