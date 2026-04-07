import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern card with various styles
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final double borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius = 16,
    this.onTap,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  /// Simple card with default styling
  const AppCard.simple({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  })  : color = AppTheme.surfaceColor,
        elevation = 0,
        borderRadius = 16,
        border = null,
        boxShadow = null,
        gradient = null;

  /// Elevated card with shadow
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 16,
  })  : color = AppTheme.surfaceColor,
        elevation = 4,
        border = null,
        boxShadow = const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        gradient = null;

  /// Outlined card with border
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color borderColor = AppTheme.dividerColor,
    double borderRadius = 16,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      onTap: onTap,
      color: AppTheme.surfaceColor,
      borderRadius: borderRadius,
      border: Border.all(color: borderColor, width: 1),
    );
  }

  /// Gradient card with gradient background
  factory AppCard.gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    double borderRadius = 16,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      onTap: onTap,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.surfaceColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow ??
            (elevation != null && elevation! > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05 * elevation!),
                      blurRadius: elevation! * 4,
                      offset: Offset(0, elevation!),
                    ),
                  ]
                : null),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Feature card with icon
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Info card with colored background
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final VoidCallback? onClose;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppTheme.primaryColor,
    this.onClose,
  });

  const InfoCard.success({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  })  : icon = Icons.check_circle,
        color = AppTheme.successColor;

  const InfoCard.warning({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  })  : icon = Icons.warning,
        color = AppTheme.warningColor;

  const InfoCard.error({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  })  : icon = Icons.error,
        color = AppTheme.errorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: color, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
