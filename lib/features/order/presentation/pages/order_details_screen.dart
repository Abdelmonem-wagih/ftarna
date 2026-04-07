import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/services/pending_order_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription? _orderSubscription;
  OrderEntity? _order;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _subscribeToOrder();
  }

  void _subscribeToOrder() {
    final orderRepo = sl<OrderRepository>();
    _orderSubscription = orderRepo.streamOrder(widget.orderId).listen(
      (order) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: _isLoading
          ? const PageLoading(message: 'Loading order...')
          : _order == null
              ? const AppErrorState.notFound(
                  title: 'Order not found',
                  description: 'This order may have been deleted',
                )
              : _buildContent(locale, l10n),
    );
  }

  Widget _buildContent(String locale, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 24),
          _buildStatusTimeline(),
          const SizedBox(height: 24),
          if (_order!.isActive) _buildEstimatedTime(),
          _buildRestaurantInfo(locale),
          const SizedBox(height: 16),
          _buildOrderItems(locale),
          const SizedBox(height: 16),
          if (_order!.deliveryInfo != null) _buildDeliveryInfo(),
          const SizedBox(height: 16),
          _buildOrderTotal(l10n),
          const SizedBox(height: 24),
          if (_order!.canAddItems) _buildAddMoreItemsButton(),
          if (_order!.canCancel) _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final statusInfo = _getStatusInfo(_order!.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo.color.withValues(alpha: 0.8),
            statusInfo.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.2 + (_pulseController.value * 0.1),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusInfo.icon,
                  color: Colors.white,
                  size: 48,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            statusInfo.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusInfo.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Order #${_order!.orderNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      // OrderStatus.preparing,
      // OrderStatus.ready,
      // OrderStatus.outForDelivery,
      OrderStatus.arrived,
    ];

    final currentIndex = statuses.indexOf(_order!.status);
    final isCancelled = _order!.status == OrderStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: AppTheme.errorColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'This order has been cancelled',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final status = statuses[index];
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;
          final info = _getStatusInfo(status);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? info.color : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: info.color, width: 3)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  if (index < statuses.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: isCompleted ? info.color : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCompleted
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          info.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEstimatedTime() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_order!.estimatedPreparationMinutes} - ${_order!.estimatedPreparationMinutes + 15} min',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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
                  _order!.getLocalizedRestaurantName(locale),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Text(
                //   _order!.getLocalizedBranchName(locale),
                //   style: TextStyle(
                //     color: AppTheme.textSecondary,
                //     fontSize: 13,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${_order!.items.length} items',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_order!.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.getLocalizedName(locale),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (item.selectedVariations.isNotEmpty)
                          Text(
                            item.selectedVariations
                                .map((v) => v.getLocalizedVariationName(locale))
                                .join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toInt()} EGP',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    final info = _order!.deliveryInfo!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  info.addressLine,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          PriceSummaryRow(
            label: l10n.subtotal,
            amount: _order!.subtotal,
          ),
          if (_order!.discount > 0)
            PriceSummaryRow(
              label: 'Discount',
              amount: _order!.discount,
              isDiscount: true,
            ),
          PriceSummaryRow(
            label: l10n.deliveryFee,
            amount: _order!.deliveryFee,
          ),
          const Divider(height: 24),
          PriceSummaryRow(
            label: l10n.total,
            amount: _order!.total,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreItemsButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: () {
          // Set pending order context for adding items
          final pendingOrderCubit = sl<PendingOrderCubit>();
          pendingOrderCubit.setPendingOrder(_order!);

          // Navigate to restaurants screen to add more items
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add More Items'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showCancelDialog(),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Cancel Order'),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final orderRepo = sl<OrderRepository>();
              await orderRepo.updateOrderStatus(
                orderId: widget.orderId,
                newStatus: OrderStatus.cancelled,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusInfo(
          title: 'Order Placed',
          description: 'Waiting for restaurant confirmation',
          icon: Icons.hourglass_empty,
          color: AppTheme.warningColor,
        );
      case OrderStatus.confirmed:
        return _StatusInfo(
          title: 'Order Confirmed',
          description: 'Restaurant is preparing your order',
          icon: Icons.check_circle_outline,
          color: Colors.blue,
        );
      // case OrderStatus.preparing:
      //   return _StatusInfo(
      //     title: 'Preparing',
      //     description: 'Your order is being prepared',
      //     icon: Icons.restaurant,
      //     color: Colors.orange,
      //   );
      // case OrderStatus.ready:
      //   return _StatusInfo(
      //     title: 'Ready for Pickup',
      //     description: 'Your order is ready for delivery',
      //     icon: Icons.takeout_dining,
      //     color: Colors.teal,
      //   );
      // case OrderStatus.outForDelivery:
      //   return _StatusInfo(
      //     title: 'Out for Delivery',
      //     description: 'Your order is on the way',
      //     icon: Icons.delivery_dining,
      //     color: Colors.indigo,
      //   );
      case OrderStatus.arrived:
        return _StatusInfo(
          title: 'Delivered',
          description: 'Enjoy your meal!',
          icon: Icons.check_circle,
          color: AppTheme.successColor,
        );
      case OrderStatus.cancelled:
        return _StatusInfo(
          title: 'Cancelled',
          description: 'Order has been cancelled',
          icon: Icons.cancel,
          color: AppTheme.errorColor,
        );
    }
  }
}

class _StatusInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _StatusInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
