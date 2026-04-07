import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// Modern status badge widget
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
    this.fontSize = 12,
    this.padding,
  });

  /// Status badge for order status
  factory StatusBadge.orderStatus(OrderStatus status) {
    return StatusBadge(
      label: status.displayName,
      color: _getOrderStatusColor(status),
      icon: _getOrderStatusIcon(status),
    );
  }

  /// Open/Closed status badge
  factory StatusBadge.openClosed({required bool isOpen}) {
    return StatusBadge(
      label: isOpen ? 'Open' : 'Closed',
      color: isOpen ? AppTheme.successColor : AppTheme.errorColor,
      icon: isOpen ? Icons.check_circle : Icons.cancel,
    );
  }

  /// Available/Unavailable status badge
  factory StatusBadge.availability({required bool isAvailable}) {
    return StatusBadge(
      label: isAvailable ? 'Available' : 'Unavailable',
      color: isAvailable ? AppTheme.successColor : AppTheme.textSecondary,
    );
  }

  /// Paid/Unpaid status badge
  factory StatusBadge.payment({required bool isPaid}) {
    return StatusBadge(
      label: isPaid ? 'Paid' : 'Unpaid',
      color: isPaid ? AppTheme.successColor : AppTheme.warningColor,
      icon: isPaid ? Icons.check_circle : Icons.pending,
    );
  }

  static Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warningColor; // Orange - waiting for confirmation
      case OrderStatus.confirmed:
        return Colors.blue; // Blue - confirmed, in progress
      case OrderStatus.arrived:
        return AppTheme.successColor; // Green - completed
      case OrderStatus.cancelled:
        return AppTheme.errorColor; // Red - cancelled
    }
  }

  static IconData _getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty; // Waiting
      case OrderStatus.confirmed:
        return Icons.check_circle_outline; // Confirmed
      case OrderStatus.arrived:
        return Icons.check_circle; // Completed
      case OrderStatus.cancelled:
        return Icons.cancel; // Cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: fontSize + 2),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag chip for categories, filters, etc.
class TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info badge (delivery time, distance, etc.)
class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
  });

  /// Delivery time badge
  factory InfoBadge.deliveryTime(int minutes) {
    return InfoBadge(
      icon: Icons.access_time,
      text: '$minutes min',
    );
  }

  /// Distance badge
  factory InfoBadge.distance(double km) {
    return InfoBadge(
      icon: Icons.location_on_outlined,
      text: km < 1 ? '${(km * 1000).toInt()} m' : '${km.toStringAsFixed(1)} km',
    );
  }

  /// Minimum order badge
  factory InfoBadge.minimumOrder(double amount) {
    return InfoBadge(
      icon: Icons.shopping_bag_outlined,
      text: 'Min ${amount.toInt()} EGP',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor ?? AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
