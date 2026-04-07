import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/order_entity.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderEntity order;
  final String locale;
  final Function(OrderStatus) onStatusChange;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.locale,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = order.createdAt;
    final timeAgo = DateTime.now().difference(createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: _getStatusColor(order.status).withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${order.orderNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Customer info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.userName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(timeAgo),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (order.userPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        order.userPhone!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Order items
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.getLocalizedName(locale)),
                        ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(0)} EGP',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          // Special instructions
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Total and actions
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final nextStatus = order.status.nextStatus;

    if (nextStatus == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        if (order.canCancel)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
            ),
          ),
        if (order.canCancel) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => onStatusChange(nextStatus),
            child: Text(_getNextActionText(order.status)),
          ),
        ),
      ],
    );
  }

  String _getNextActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Accept Order';
      case OrderStatus.confirmed:
        return 'Start Preparing';
      // case OrderStatus.preparing:
      //   return 'Mark Ready';
      // case OrderStatus.ready:
      //   return 'Out for Delivery';
      case OrderStatus.arrived:
        return 'Mark Delivered';
      default:
        return 'Next';
    }
  }

  void _showCancelDialog(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
                onStatusChange(OrderStatus.cancelled);
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
      // case OrderStatus.preparing:
      //   return Colors.purple;
      // case OrderStatus.ready:
      //   return Colors.teal;
      // case OrderStatus.outForDelivery:
      //   return Colors.indigo;
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
      // case OrderStatus.preparing:
      //   return Icons.restaurant;
      // case OrderStatus.ready:
      //   return Icons.check_box;
      // case OrderStatus.outForDelivery:
      //   return Icons.delivery_dining;
      case OrderStatus.arrived:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }
}
