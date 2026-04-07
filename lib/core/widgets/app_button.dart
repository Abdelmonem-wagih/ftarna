import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }
enum AppButtonSize { small, medium, large }

/// Modern app button with various styles and loading state
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = AppButtonVariant.primary,
        size = AppButtonSize.medium;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = AppButtonVariant.secondary,
        size = AppButtonSize.medium;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = AppButtonVariant.outline,
        size = AppButtonSize.medium;

  const AppButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
  })  : variant = AppButtonVariant.ghost,
        size = AppButtonSize.medium;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getHeight();
    final buttonPadding = _getPadding();
    final textStyle = _getTextStyle();

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_getForegroundColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: textStyle),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 20),
              ],
            ],
          );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: foregroundColor ?? Colors.white,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            padding: buttonPadding,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
            foregroundColor: foregroundColor ?? AppTheme.primaryColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            padding: buttonPadding,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppTheme.primaryColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            padding: buttonPadding,
            side: BorderSide(
              color: backgroundColor ?? AppTheme.primaryColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.ghost:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? AppTheme.primaryColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    return button;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppTheme.primaryColor;
    }
  }
}

/// Icon button with modern styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool hasBadge;
  final int badgeCount;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.backgroundColor,
    this.iconColor,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: iconColor ?? AppTheme.textPrimary,
            ),
            iconSize: size * 0.5,
            padding: EdgeInsets.zero,
          ),
        ),
        if (hasBadge && badgeCount > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
