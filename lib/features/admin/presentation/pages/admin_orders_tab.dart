import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../cubit/admin_cubit.dart';

class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noOrders,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats row
              _buildStatsRow(context, state),
              // Orders list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return _OrderCard(order: order);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, AdminLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatChip(
            label: context.l10n.total,
            value: state.totalOrders.toString(),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: context.l10n.paid,
            value: state.paidOrders.toString(),
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: context.l10n.notPaid,
            value: state.unpaidOrders.toString(),
            color: AppTheme.warningColor,
          ),
          if (state.cancelledOrders > 0) ...[
            const SizedBox(width: 8),
            _StatChip(
              label: context.l10n.cancelled,
              value: state.cancelledOrders.toString(),
              color: AppTheme.errorColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (order.isCancelled) {
      statusColor = AppTheme.errorColor;
      statusText = context.l10n.cancelled;
    } else if (order.isPaid) {
      statusColor = AppTheme.successColor;
      statusText = context.l10n.paid;
    } else {
      statusColor = AppTheme.warningColor;
      statusText = context.l10n.notPaid;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            order.isCancelled
                ? Icons.cancel
                : order.isPaid
                    ? Icons.check
                    : Icons.pending,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          order.userName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${order.totalItems} ${context.l10n.items} • ${order.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.name),
                          ),
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(item.price * item.quantity).toStringAsFixed(2)} ${context.l10n.egp}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                // Action buttons
                if (!order.isCancelled)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!order.isPaid) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            _showCancelDialog(context, order);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: Text(context.l10n.cancel),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AdminCubit>().markOrderPaid(order.id);
                          },
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.markAsPaid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.cancelOrder),
        content: Text(context.l10n.confirmCancel),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.no),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminCubit>().cancelOrder(order.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );
  }
}
