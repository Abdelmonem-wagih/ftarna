import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  StreamSubscription? _orderSubscription;
  OrderEntity? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : _buildOrderContent(locale),
    );
  }

  Widget _buildOrderContent(String locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          _buildOrderHeader(locale),
          const SizedBox(height: 24),

          // Status tracker
          _buildStatusTracker(),
          const SizedBox(height: 24),

          // Estimated time
          if (_order!.isActive) ...[
            _buildEstimatedTime(),
            const SizedBox(height: 24),
          ],

          // Restaurant info
          _buildRestaurantInfo(locale),
          const SizedBox(height: 24),

          // Order items
          _buildOrderItems(locale),
          const SizedBox(height: 24),

          // Order total
          _buildOrderTotal(),
          const SizedBox(height: 24),

          // Delivery info
          if (_order!.deliveryInfo != null) ...[
            _buildDeliveryInfo(),
            const SizedBox(height: 24),
          ],

          // Actions
          if (_order!.canAddItems) _buildAddMoreItemsButton(),
          if (_order!.canCancel) _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(String locale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(_order!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(_order!.status),
                color: _getStatusColor(_order!.status),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${_order!.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _order!.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(_order!.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker() {
    // Simple 3-status timeline
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.arrived,
    ];
    final currentIndex = statuses.indexOf(_order!.status);

    final isCancelled = _order!.status == OrderStatus.cancelled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isCancelled
            ? Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Order Cancelled',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: List.generate(statuses.length, (index) {
                  final status = statuses[index];
                  final isCompleted = index <= currentIndex;
                  final isCurrent = index == currentIndex;

                  return Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (index < statuses.length - 1)
                            Container(
                              width: 2,
                              height: 30,
                              color: isCompleted
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          status.displayName,
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted ? null : Colors.grey,
                          ),
                        ),
                      ),
                      if (isCurrent && _getStatusTime(status) != null)
                        Text(
                          _formatTime(_getStatusTime(status)!),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  );
                }),
              ),
      ),
    );
  }

  Widget _buildEstimatedTime() {
    final estimatedTime = _order!.estimatedDeliveryTime;
    if (estimatedTime == null) return const SizedBox();

    final remaining = estimatedTime.difference(DateTime.now());
    final minutes = remaining.inMinutes;

    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Delivery',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    minutes > 0
                        ? 'In about $minutes minutes'
                        : 'Arriving soon!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(String locale) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant),
        title: Text(_order!.getLocalizedRestaurantName(locale)),

      ),
    );
  }

  Widget _buildOrderItems(String locale) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Order Items',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...(_order!.items.map((item) {
            return ListTile(
              title: Text(item.getLocalizedName(locale)),
              trailing: Text(
                '${item.quantity}x ${item.unitPrice.toStringAsFixed(0)} EGP',
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildOrderTotal() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', _order!.subtotal),
            const SizedBox(height: 8),
            _buildTotalRow('Delivery Fee', _order!.deliveryFee),
            if (_order!.discount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('Discount', -_order!.discount, isDiscount: true),
            ],
            const Divider(height: 24),
            _buildTotalRow('Total', _order!.total, isBold: true),
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
            color: isDiscount ? Colors.green : null,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} EGP',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final info = _order!.deliveryInfo!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 8),
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(info.addressLine),
            if (info.buildingName != null)
              Text('Building: ${info.buildingName}'),
            if (info.floor != null) Text('Floor: ${info.floor}'),
            if (info.deliveryInstructions != null)
              Text(
                'Note: ${info.deliveryInstructions}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreItemsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate back to restaurant
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add More Items'),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => _showCancelDialog(),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Cancel Order'),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final orderRepo = sl<OrderRepository>();
                await orderRepo.cancelOrderWithReason(widget.orderId, null);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.arrived:
        return Colors.green;
        case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
        case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.arrived:
        return Icons.done_all;
    }
  }

  DateTime? _getStatusTime(OrderStatus status) {
    final entry = _order!.statusHistory.where((h) => h.status == status);
    if (entry.isNotEmpty) {
      return entry.first.timestamp;
    }
    return null;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
