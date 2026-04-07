import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../common/widgets/loading_widget.dart';
import '../cubit/order_cubit.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderCubit>().loadUserOrder(authState.user.id);
    }
  }

  void _repeatLastOrder() {
    final authState = context.read<AuthCubit>().state;
    final orderState = context.read<OrderCubit>().state;

    if (authState is! AuthAuthenticated) return;
    if (orderState is! OrderLoaded || orderState.lastOrder == null) return;

    context.read<OrderCubit>().repeatLastOrder(
      sessionId: '', // No longer using sessions
      userId: authState.user.id,
      userName: authState.user.name,
      lastOrder: orderState.lastOrder!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myOrder),
      ),
      body: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSubmitted) {
            context.showSuccessSnackBar(context.l10n.orderSubmitted);
          } else if (state is OrderError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const LoadingWidget();
            }

            if (state is OrderLoaded) {
              return _buildOrderContent(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrderContent(OrderLoaded state) {
    final currentOrder = state.currentOrder;
    final lastOrder = state.lastOrder;

    if (currentOrder == null || currentOrder.isCancelled) {
      return _buildNoOrder(lastOrder);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order status card
              _buildStatusCard(currentOrder.isPaid, currentOrder.isCancelled),
              const SizedBox(height: 16),
              // Order items
              ...currentOrder.items.map((item) => _buildOrderItemCard(item)),
              const SizedBox(height: 16),
              // Order summary
              _buildSummaryCard(currentOrder),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoOrder(dynamic lastOrder) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noOrders,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (lastOrder != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _repeatLastOrder,
                icon: const Icon(Icons.replay),
                label: Text(context.l10n.repeatLastOrder),
              ),
              const SizedBox(height: 8),
              Text(
                '${lastOrder.totalItems} ${context.l10n.items} • ${lastOrder.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isPaid, bool isCancelled) {
    Color color;
    IconData icon;
    String text;

    if (isCancelled) {
      color = AppTheme.errorColor;
      icon = Icons.cancel;
      text = context.l10n.cancelled;
    } else if (isPaid) {
      color = AppTheme.successColor;
      icon = Icons.check_circle;
      text = context.l10n.paid;
    } else {
      color = AppTheme.warningColor;
      icon = Icons.pending;
      text = context.l10n.notPaid;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${item.price.toStringAsFixed(2)} ${context.l10n.egp}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x${item.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(dynamic order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.subtotal,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.total,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
