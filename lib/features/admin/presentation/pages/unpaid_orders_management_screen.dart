import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/user_orders_summary.dart';
import '../cubit/restaurant_orders_cubit.dart';

/// Screen for managing unpaid orders
/// Shows users with unpaid orders and allows admin to mark orders as paid
class UnpaidOrdersManagementScreen extends StatelessWidget {
  const UnpaidOrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unpaid Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
              builder: (context, state) {
                if (state is RestaurantOrdersLoaded) {
                  return Text(
                    '${state.usersWithUnpaidOrders.length} users • ${state.totalUnpaid.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
        builder: (context, state) {
          if (state is! RestaurantOrdersLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final usersWithUnpaid = state.usersWithUnpaidOrders;

          if (usersWithUnpaid.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppTheme.successColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All orders are paid! 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usersWithUnpaid.length,
            itemBuilder: (context, index) {
              final summary = usersWithUnpaid[index];
              return _UnpaidUserCard(summary: summary);
            },
          );
        },
      ),
    );
  }
}

class _UnpaidUserCard extends StatefulWidget {
  final UserOrdersSummary summary;

  const _UnpaidUserCard({required this.summary});

  @override
  State<_UnpaidUserCard> createState() => _UnpaidUserCardState();
}

class _UnpaidUserCardState extends State<_UnpaidUserCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final unpaidOrders = widget.summary.unpaidOrdersList;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with warning badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                        child: Text(
                          widget.summary.userName.isNotEmpty
                              ? widget.summary.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.summary.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${unpaidOrders.length} unpaid ${unpaidOrders.length == 1 ? 'order' : 'orders'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.summary.unpaidAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      Text(
                        'EGP',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Orders List
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unpaidOrders.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final order = unpaidOrders[index];
                  return _buildOrderItem(context, order);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderEntity order) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items Summary
          ...order.items.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '×${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.getLocalizedName(locale),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (order.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${order.items.length - 3} more items',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Mark as Paid Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _markAsPaid(context, order.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(context.l10n.markAsPaid),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(context.l10n.confirmPaid),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<RestaurantOrdersCubit>().markOrderAsPaid(orderId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as paid ✓'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
