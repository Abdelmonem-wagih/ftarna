import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartEntity cart;

  const CheckoutScreen({
    super.key,
    required this.cart,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isLoading = false;
  DeliveryInfo? _deliveryInfo;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Delivery Address Section
            // _buildSectionTitle('Delivery Address'),
            // _buildDeliveryAddressCard(context, locale),
            const SizedBox(height: 24),

            // Order Items Section
            _buildSectionTitle('Order Summary'),
            _buildOrderItemsCard(locale),
            const SizedBox(height: 24),

            // Payment Method Section
            _buildSectionTitle('Payment Method'),
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionTitle('Special Instructions'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requests?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Total Section
            _buildOrderTotalCard(locale),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, l10n),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard(BuildContext context, String locale) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: const Text('Add Delivery Address'),
        subtitle: _deliveryInfo != null
            ? Text(_deliveryInfo!.addressLine)
            : const Text('Tap to add address'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAddressDialog(context),
      ),
    );
  }

  Widget _buildOrderItemsCard(String locale) {
    return Card(
      child: Column(
        children: [
          ...widget.cart.items.map((item) {
            return ListTile(
              title: Text(item.getLocalizedName(locale)),
              subtitle: item.selectedVariations.isNotEmpty
                  ? Text(
                      item.selectedVariations
                          .map((v) => v.getLocalizedVariationName(locale))
                          .join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    )
                  : null,
              trailing: Text(
                '${item.quantity}x ${item.unitPrice.toStringAsFixed(0)} EGP',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when you receive your order'),
            value: 'cash',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Card Payment'),
            subtitle: const Text('Coming soon'),
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: null, // Disabled for now
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotalCard(String locale) {
    final deliveryFee = 15.0; // TODO: Get from branch

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', widget.cart.subtotal),
            const SizedBox(height: 8),
            _buildTotalRow('Delivery Fee', deliveryFee),
            if (widget.cart.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow(
                'Discount',
                -widget.cart.discountAmount,
                isDiscount: true,
              ),
            ],
            const Divider(height: 24),
            _buildTotalRow(
              'Total',
              widget.cart.total + deliveryFee,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
            color: isDiscount ? Colors.green : null,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} EGP',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    final addressController = TextEditingController();
    final buildingController = TextEditingController();
    final floorController = TextEditingController();
    final instructionsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: buildingController,
                      decoration: const InputDecoration(
                        labelText: 'Building',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: floorController,
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Instructions (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (addressController.text.isNotEmpty) {
                      setState(() {
                        _deliveryInfo = DeliveryInfo(
                          addressLine: addressController.text,
                          buildingName: buildingController.text.isEmpty
                              ? null
                              : buildingController.text,
                          floor: floorController.text.isEmpty
                              ? null
                              : floorController.text,
                          deliveryInstructions:
                              instructionsController.text.isEmpty
                                  ? null
                                  : instructionsController.text,
                          latitude: 30.0444, // TODO: Get from location
                          longitude: 31.2357,
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Address'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('Please login to place an order');
      }

      final user = authState.user;
      final orderRepo = sl<OrderRepository>();

      final deliveryFee = 15.0; // TODO: Get from branch

      final order = await orderRepo.createOrderFromCart(
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        restaurantId: widget.cart.restaurantId!,
        restaurantNameAr: widget.cart.restaurantNameAr!,
        restaurantNameEn: widget.cart.restaurantNameEn!,
        // branchId: widget.cart.branchId!,
        // branchNameAr: widget.cart.branchNameAr!,
        // branchNameEn: widget.cart.branchNameEn!,
        items: widget.cart.items.map((i) => i.toOrderItem()).toList(),
        subtotal: widget.cart.subtotal,
        deliveryFee: deliveryFee,
        discount: widget.cart.discountAmount,
        discountCode: widget.cart.discountCode,
        offerId: widget.cart.offerId,
        // deliveryInfo: _deliveryInfo,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Clear cart
      context.read<CartCubit>().clearCart();

      // Navigate to order tracking
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: order.id),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
