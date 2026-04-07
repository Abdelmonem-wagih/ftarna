import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern price tag widget
class PriceTag extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currency;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final bool showCurrency;

  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'EGP',
    this.fontSize = 16,
    this.color,
    this.fontWeight = FontWeight.bold,
    this.showCurrency = true,
  });

  const PriceTag.large({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'EGP',
    this.color,
  })  : fontSize = 24,
        fontWeight = FontWeight.bold,
        showCurrency = true;

  const PriceTag.small({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'EGP',
    this.color,
  })  : fontSize = 14,
        fontWeight = FontWeight.w600,
        showCurrency = true;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${price.toStringAsFixed(0)}${showCurrency ? ' $currency' : ''}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: hasDiscount
                ? AppTheme.primaryColor
                : (color ?? AppTheme.textPrimary),
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            '${originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.normal,
              color: AppTheme.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

/// Price summary row
class PriceSummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final bool isTotal;
  final bool isDiscount;
  final Color? valueColor;

  const PriceSummaryRow({
    super.key,
    required this.label,
    required this.amount,
    this.currency = 'EGP',
    this.isTotal = false,
    this.isDiscount = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.toStringAsFixed(0)} $currency',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (isDiscount
                      ? AppTheme.successColor
                      : (isTotal
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Discount badge
class DiscountBadge extends StatelessWidget {
  final int percentage;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const DiscountBadge({
    super.key,
    required this.percentage,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-$percentage%',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Free delivery badge
class FreeDeliveryBadge extends StatelessWidget {
  const FreeDeliveryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: AppTheme.successColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Free Delivery',
            style: TextStyle(
              color: AppTheme.successColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
