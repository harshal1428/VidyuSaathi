import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? (isDark ? AppColors.darkPrimaryForeground : AppColors.lightPrimaryForeground),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final Border? border;
  final double? elevation;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = const EdgeInsets.all(0),
    this.backgroundColor,
    this.border,
    this.elevation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
          border: border ?? Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: elevation != null ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: elevation!,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final BadgeVariant variant;

  const AppBadge({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.variant = BadgeVariant.default_,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bgColor;
    Color txtColor;

    switch (variant) {
      case BadgeVariant.default_:
        bgColor = backgroundColor ?? (isDark ? AppColors.darkSecondary : AppColors.lightSecondary);
        txtColor = textColor ?? (isDark ? AppColors.darkSecondaryForeground : AppColors.lightSecondaryForeground);
        break;
      case BadgeVariant.destructive:
        bgColor = backgroundColor ?? AppColors.lightDestructive;
        txtColor = textColor ?? AppColors.lightDestructiveForeground;
        break;
      case BadgeVariant.accent:
        bgColor = backgroundColor ?? (isDark ? AppColors.darkAccent : AppColors.lightAccent);
        txtColor = textColor ?? (isDark ? AppColors.darkAccentForeground : AppColors.lightAccentForeground);
        break;
      case BadgeVariant.outline:
        bgColor = Colors.transparent;
        txtColor = isDark ? AppColors.darkForeground : AppColors.lightForeground;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: variant == BadgeVariant.outline
            ? Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              )
            : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: txtColor,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }
}

enum BadgeVariant {
  default_,
  destructive,
  accent,
  outline,
}

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSuffixIconPressed;
  final bool isReadOnly;

  const AppInput({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSuffixIconPressed,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          obscureText: _obscureText,
          readOnly: widget.isReadOnly,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconPressed,
                    child: Icon(widget.suffixIcon),
                  )
                : null,
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.lightDestructive,
            ),
          ),
        ],
      ],
    );
  }
}

class AppSelect<T> extends StatefulWidget {
  final String? label;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  const AppSelect({
    Key? key,
    this.label,
    required this.items,
    this.selectedItem,
    required this.itemLabel,
    this.onChanged,
    this.hint,
  }) : super(key: key);

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          value: widget.selectedItem,
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(widget.itemLabel(item)),
            );
          }).toList(),
          onChanged: widget.onChanged,
          hint: widget.hint != null ? Text(widget.hint!) : null,
        ),
      ],
    );
  }
}


