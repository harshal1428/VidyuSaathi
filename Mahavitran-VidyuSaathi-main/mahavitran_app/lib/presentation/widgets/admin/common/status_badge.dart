import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({
    Key? key,
    required this.status,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    late Color backgroundColor;
    late Color textColor;

    switch (status.toLowerCase()) {
      case 'normal':
        backgroundColor = AppColors.statusNormal;
        textColor = Colors.white;
        break;
      case 'overloaded':
        backgroundColor = AppColors.statusOverloaded;
        textColor = Colors.white;
        break;
      case 'critical':
        backgroundColor = AppColors.statusCritical;
        textColor = Colors.white;
        break;
      case 'high':
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        break;
      case 'medium':
        backgroundColor = const Color(0xFF3B82F6);
        textColor = Colors.white;
        break;
      case 'low':
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        break;
      default:
        backgroundColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
        textColor = isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        customLabel ?? status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({
    Key? key,
    required this.priority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;
    late IconData icon;

    switch (priority.toLowerCase()) {
      case 'critical':
        backgroundColor = AppColors.statusCritical;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case 'high':
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        icon = Icons.arrow_upward;
        break;
      case 'medium':
        backgroundColor = const Color(0xFF3B82F6);
        textColor = Colors.white;
        icon = Icons.remove;
        break;
      case 'low':
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        icon = Icons.arrow_downward;
        break;
      default:
        backgroundColor = const Color(0xFF6B7280);
        textColor = Colors.white;
        icon = Icons.help;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            priority,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: textColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightDestructive,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor ?? AppColors.lightDestructiveForeground,
            fontWeight: AppFontWeights.bold,
          ),
        ),
      ),
    );
  }
}
