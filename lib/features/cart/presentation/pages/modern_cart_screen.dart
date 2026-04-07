import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../../../order/presentation/pages/checkout_screen.dart';

class ModernCartScreen extends StatelessWidget {
  const ModernCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.myOrder,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(context),
                  child: Text(
                    'Clear',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const PageLoading();
          }

          if (state is CartEmpty || state is CartInitial) {
            return AppEmptyState.emptyCart(
              onAction: () => Navigator.pop(context),
            );
          }

          if (state is CartError) {
            return AppErrorState.general(
              description: state.message,
              onRetry: () {
                // Reload cart
              },
            );
          }

          if (state is CartLoaded || state is CartUpdating) {
            final cart = state.cart;
            if (cart == null || cart.isEmpty) {
              return AppEmptyState.emptyCart(
                onAction: () => Navigator.pop(context),
              );
            }
            return _buildCartContent(context, cart, locale, l10n);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartEntity cart,
    String locale,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Restaurant info
        _buildRestaurantHeader(cart, locale),
        // Cart items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModernCartItemCard(
                  item: item,
                  locale: locale,
                  onQuantityChanged: (quantity) {
                    if (quantity <= 0) {
                      context.read<CartCubit>().removeItem(item.id);
                    } else {
                      context.read<CartCubit>().updateQuantity(item.id, quantity);
                    }
                  },
                  onRemove: () {
                    context.read<CartCubit>().removeItem(item.id);
                  },
                ),
              );
            },
          ),
        ),
        // Order summary and checkout button
        _buildCheckoutSection(context, cart, l10n),
      ],
    );
  }

  Widget _buildRestaurantHeader(CartEntity cart, String locale) {
    final restaurantName = cart.getLocalizedRestaurantName(locale);
    final branchName = cart.getLocalizedBranchName(locale);

    if (restaurantName == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (branchName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    branchName,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${cart.totalItems} items',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartEntity cart,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Discount code
            if (cart.discountCode == null) _buildDiscountInput(context),
            if (cart.discountCode != null)
              _buildAppliedDiscount(context, cart),
            const SizedBox(height: 16),
            // Price summary
            PriceSummaryRow(
              label: l10n.subtotal,
              amount: cart.subtotal,
            ),
            if (cart.discountAmount > 0)
              PriceSummaryRow(
                label: 'Discount',
                amount: cart.discountAmount,
                isDiscount: true,
              ),
            const Divider(height: 24),
            PriceSummaryRow(
              label: l10n.total,
              amount: cart.total,
              isTotal: true,
            ),
            const SizedBox(height: 20),
            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(cart: cart),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.placeOrder} • ${cart.total.toStringAsFixed(0)} EGP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountInput(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.local_offer_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter discount code',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CartCubit>().applyDiscountCode(controller.text);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedDiscount(BuildContext context, CartEntity cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: AppTheme.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Code "${cart.discountCode}" applied',
              style: TextStyle(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<CartCubit>().removeDiscountCode();
            },
            child: Icon(
              Icons.close,
              color: AppTheme.successColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Modern cart item card
class ModernCartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final String locale;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const ModernCartItemCard({
    super.key,
    required this.item,
    required this.locale,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.getLocalizedName(locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.selectedVariations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.selectedVariations
                          .map((v) => v.getLocalizedVariationName(locale))
                          .join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.specialInstructions != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.specialInstructions!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceTag(
                        price: item.totalPrice,
                        fontSize: 16,
                      ),
                      CompactQuantitySelector(
                        quantity: item.quantity,
                        minQuantity: 0,
                        onChanged: onQuantityChanged,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
