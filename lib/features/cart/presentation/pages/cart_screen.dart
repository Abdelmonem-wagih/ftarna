import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_card.dart';
import '../../../order/presentation/pages/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrder),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartEmpty || state is CartInitial) {
            return _buildEmptyCart(context, l10n);
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reload cart
                    },
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (state is CartLoaded || state is CartUpdating) {
            final cart = state.cart;
            if (cart == null || cart.isEmpty) {
              return _buildEmptyCart(context, l10n);
            }
            return _buildCartContent(context, cart, locale, l10n);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyCart,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to start your order',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Restaurants'),
          ),
        ],
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
        if (cart.getLocalizedRestaurantName(locale) != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.restaurant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.getLocalizedRestaurantName(locale)!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (cart.getLocalizedBranchName(locale) != null)
                        Text(
                          cart.getLocalizedBranchName(locale)!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        // Cart items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartItemCard(
                  item: item,
                  locale: locale,
                  onQuantityChanged: (quantity) {
                    context.read<CartCubit>().updateQuantity(item.id, quantity);
                  },
                  onRemove: () {
                    context.read<CartCubit>().removeItem(item.id);
                  },
                ),
              );
            },
          ),
        ),
        // Discount code input
        _buildDiscountSection(context, cart, l10n),
        // Order summary
        _buildOrderSummary(context, cart, l10n),
      ],
    );
  }

  Widget _buildDiscountSection(
    BuildContext context,
    CartEntity cart,
    AppLocalizations l10n,
  ) {
    if (cart.discountCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Code "${cart.discountCode}" applied',
                style: const TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<CartCubit>().removeDiscount();
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter discount code',
                prefixIcon: const Icon(Icons.local_offer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (code) {
                if (code.isNotEmpty) {
                  context.read<CartCubit>().applyDiscountCode(code);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    CartEntity cart,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.subtotal),
                Text('${cart.subtotal.toStringAsFixed(2)} EGP'),
              ],
            ),
            if (cart.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discount',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    '-${cart.discountAmount.toStringAsFixed(2)} EGP',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${cart.total.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Proceed to Checkout (${cart.totalItems} items)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartCubit>().clearCart();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
