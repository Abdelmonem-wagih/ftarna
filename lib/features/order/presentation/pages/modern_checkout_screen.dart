import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/services/pending_order_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'modern_order_tracking_screen.dart';

class ModernCheckoutScreen extends StatefulWidget {
  final CartEntity cart;

  const ModernCheckoutScreen({
    super.key,
    required this.cart,
  });

  @override
  State<ModernCheckoutScreen> createState() => _ModernCheckoutScreenState();
}

class _ModernCheckoutScreenState extends State<ModernCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'cash';
  bool _isLoading = false;
  int _currentStep = 0;

  final double _deliveryFee = 15.0; // TODO: Get from branch

  double get _total => widget.cart.total + _deliveryFee;

  @override
  void dispose() {
    _addressController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) _buildDeliveryStep(locale),
                    if (_currentStep == 1) _buildPaymentStep(),
                    if (_currentStep == 2) _buildConfirmStep(locale, l10n),
                  ],
                ),
              ),
            ),
            // Bottom bar
            _buildBottomBar(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Delivery', 'Payment', 'Confirm'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < _currentStep
                    ? AppTheme.primaryColor
                    : AppTheme.dividerColor,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isCurrent = stepIndex == _currentStep;

          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: stepIndex < _currentStep
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  color: isCurrent
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDeliveryStep(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Delivery Address'),
        const SizedBox(height: 16),
        // Address input
        _buildInputField(
          controller: _addressController,
          label: 'Address',
          hint: 'Street name, area...',
          icon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Building and floor row
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _buildingController,
                label: 'Building',
                hint: 'Building name/number',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _floorController,
                label: 'Floor',
                hint: 'Floor number',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _apartmentController,
          label: 'Apartment',
          hint: 'Apartment number',
        ),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _instructionsController,
          label: 'Delivery Instructions',
          hint: 'E.g., Ring the bell twice...',
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        // Order notes
        _buildSectionTitle('Order Notes'),
        const SizedBox(height: 12),
        _buildInputField(
          controller: _notesController,
          label: 'Special Instructions',
          hint: 'Any special requests for the restaurant...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Method'),
        const SizedBox(height: 16),
        _buildPaymentOption(
          value: 'cash',
          icon: Icons.money,
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive your order',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: 'card',
          icon: Icons.credit_card,
          title: 'Credit/Debit Card',
          subtitle: 'Coming soon',
          enabled: false,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: 'wallet',
          icon: Icons.account_balance_wallet,
          title: 'Digital Wallet',
          subtitle: 'Coming soon',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    bool enabled = true,
  }) {
    final isSelected = _paymentMethod == value;

    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() {
                _paymentMethod = value;
              });
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: _paymentMethod,
                onChanged: enabled
                    ? (v) {
                        setState(() {
                          _paymentMethod = v!;
                        });
                      }
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmStep(String locale, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order items
        _buildSectionTitle('Order Summary'),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...widget.cart.items.map((item) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      imageUrl: item.imageUrl,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Text(
                    item.getLocalizedName(locale),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: item.selectedVariations.isNotEmpty
                      ? Text(
                          item.selectedVariations
                              .map((v) => v.getLocalizedVariationName(locale))
                              .join(', '),
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                  trailing: Text(
                    '${item.quantity}x ${item.unitPrice.toInt()} EGP',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Delivery address summary
        _buildSectionTitle('Delivery Address'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _addressController.text,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (_buildingController.text.isNotEmpty ||
                        _floorController.text.isNotEmpty)
                      Text(
                        '${_buildingController.text}${_floorController.text.isNotEmpty ? ', Floor ${_floorController.text}' : ''}${_apartmentController.text.isNotEmpty ? ', Apt ${_apartmentController.text}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Payment method summary
        _buildSectionTitle('Payment Method'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                _paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _paymentMethod == 'cash'
                      ? 'Cash on Delivery'
                      : 'Credit Card',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Price breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              PriceSummaryRow(
                label: l10n.subtotal,
                amount: widget.cart.subtotal,
              ),
              if (widget.cart.discountAmount > 0)
                PriceSummaryRow(
                  label: 'Discount',
                  amount: widget.cart.discountAmount,
                  isDiscount: true,
                ),
              PriceSummaryRow(
                label: l10n.deliveryFee,
                amount: _deliveryFee,
              ),
              const Divider(height: 24),
              PriceSummaryRow(
                label: l10n.total,
                amount: _total,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == 2
                            ? 'Place Order • ${_total.toStringAsFixed(0)} EGP'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your address')),
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      _submitOrder();
    }
  }

  Future<void> _submitOrder() async {
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
      final pendingOrderCubit = sl<PendingOrderCubit>();
      final pendingOrderState = pendingOrderCubit.state;

      // Check if we're adding to an existing pending order
      final pendingOrder = pendingOrderState.isAddingToExisting
          ? pendingOrderState.pendingOrder
          : await orderRepo.getUserPendingOrder(user.id);

      // Create order items
      final orderItems = widget.cart.items.map((item) => item.toOrderItem()).toList();

      OrderEntity finalOrder;

      if (pendingOrder != null && pendingOrder.restaurantId == widget.cart.restaurantId) {
        // Add items to existing pending order
        finalOrder = await orderRepo.addItemsToPendingOrder(
          orderId: pendingOrder.id,
          items: orderItems,
        );

        // Clear pending order context
        pendingOrderCubit.clearPendingOrder();
      } else {
        // Create new order
        // Create delivery info
        final deliveryInfo = DeliveryInfo(
          addressLine: _addressController.text,
          buildingName: _buildingController.text.isNotEmpty
              ? _buildingController.text
              : null,
          floor: _floorController.text.isNotEmpty ? _floorController.text : null,
          apartment: _apartmentController.text.isNotEmpty
              ? _apartmentController.text
              : null,
          deliveryInstructions: _instructionsController.text.isNotEmpty
              ? _instructionsController.text
              : null,
          latitude: 0, // TODO: Get from location service
          longitude: 0,
        );

        // Create order
        final order = OrderEntity(
          id: const Uuid().v4(),
          orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          userId: user.id,
          userName: user.name ?? 'User',
          userPhone: user.phone,
          restaurantId: widget.cart.restaurantId ?? '',
          restaurantNameAr: widget.cart.restaurantNameAr ?? '',
          restaurantNameEn: widget.cart.restaurantNameEn ?? '',
          // branchId: widget.cart.branchId ?? '',
          // branchNameAr: widget.cart.branchNameAr ?? '',
          // branchNameEn: widget.cart.branchNameEn ?? '',
          items: orderItems,
          status: OrderStatus.pending,
          subtotal: widget.cart.subtotal,
          deliveryFee: _deliveryFee,
          discount: widget.cart.discountAmount,
          total: _total,
          discountCode: widget.cart.discountCode,
          deliveryInfo: deliveryInfo,
          paymentMethod: _paymentMethod,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          createdAt: DateTime.now(),
        );

        finalOrder = await orderRepo.createOrder(order);
      }

      // Clear cart
      context.read<CartCubit>().clearCart();

      // Navigate to order tracking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ModernOrderTrackingScreen(
            orderId: finalOrder.id,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
