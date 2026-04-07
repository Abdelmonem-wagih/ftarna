import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Modern empty state widget
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
  });

  /// Empty state for no items
  const AppEmptyState.noItems({
    super.key,
    this.title = 'No items found',
    this.description,
    this.actionText,
    this.onAction,
  })  : icon = Icons.inbox_outlined,
        iconSize = 80,
        iconColor = null;

  /// Empty state for search results
  const AppEmptyState.noResults({
    super.key,
    this.title = 'No results found',
    this.description = 'Try adjusting your search or filters',
    this.actionText = 'Clear filters',
    this.onAction,
  })  : icon = Icons.search_off,
        iconSize = 80,
        iconColor = null;

  /// Empty state for empty cart
  const AppEmptyState.emptyCart({
    super.key,
    this.title = 'Your cart is empty',
    this.description = 'Add items to start your order',
    this.actionText = 'Browse Menu',
    this.onAction,
  })  : icon = Icons.shopping_cart_outlined,
        iconSize = 80,
        iconColor = null;

  /// Empty state for no orders
  const AppEmptyState.noOrders({
    super.key,
    this.title = 'No orders yet',
    this.description = 'Your order history will appear here',
    this.actionText = 'Start Ordering',
    this.onAction,
  })  : icon = Icons.receipt_long_outlined,
        iconSize = 80,
        iconColor = null;

  /// Empty state for no restaurants
  const AppEmptyState.noRestaurants({
    super.key,
    this.title = 'No restaurants found',
    this.description = 'Try expanding your search area',
    this.actionText,
    this.onAction,
  })  : icon = Icons.restaurant_outlined,
        iconSize = 80,
        iconColor = null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.textSecondary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            AppButton.primary(
              text: actionText!,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple inline empty state
class InlineEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onRefresh;

  const InlineEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }
}
