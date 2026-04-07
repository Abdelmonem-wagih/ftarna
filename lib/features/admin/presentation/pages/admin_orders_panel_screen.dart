import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../cubit/admin_cubit.dart';

class AdminOrdersPanelScreen extends StatefulWidget {
  const AdminOrdersPanelScreen({super.key});

  @override
  State<AdminOrdersPanelScreen> createState() => _AdminOrdersPanelScreenState();
}

class _AdminOrdersPanelScreenState extends State<AdminOrdersPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AdminCubit>().loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.admin,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(text: l10n.orders),
            const Tab(text: 'Dashboard'),
            Tab(text: l10n.menu),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminOrdersKanban(),
          AdminDashboard(),
          AdminMenuManagement(),
        ],
      ),
    );
  }
}

/// Kanban-style orders view
class AdminOrdersKanban extends StatefulWidget {
  const AdminOrdersKanban({super.key});

  @override
  State<AdminOrdersKanban> createState() => _AdminOrdersKanbanState();
}

class _AdminOrdersKanbanState extends State<AdminOrdersKanban> {
  StreamSubscription? _ordersSubscription;
  Map<OrderStatus, List<OrderEntity>> _ordersByStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscribeToOrders();
  }

  void _subscribeToOrders() {
    final orderRepo = sl<OrderRepository>();
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.currentUser;

    if (user == null || user.restaurantId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _ordersSubscription = orderRepo
        .streamRestaurantOrders(
          restaurantId: user.restaurantId!,
        )
        .listen(
      (orders) {
        final groupedOrders = <OrderStatus, List<OrderEntity>>{};
        for (final status in OrderStatus.values) {
          groupedOrders[status] =
              orders.where((o) => o.status == status).toList();
        }
        setState(() {
          _ordersByStatus = groupedOrders;
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
    _ordersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return const PageLoading();
    }

    final activeStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.arrived,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activeStatuses.map((status) {
          final orders = _ordersByStatus[status] ?? [];
          return _buildStatusColumn(status, orders, locale);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusColumn(
    OrderStatus status,
    List<OrderEntity> orders,
    String locale,
  ) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusInfo.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusInfo.icon, color: statusInfo.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusInfo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusInfo.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusInfo.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        'No orders',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(order, status, locale);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    OrderEntity order,
    OrderStatus currentStatus,
    String locale,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatTime(order.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.userName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.items.length} items • ${order.total.toInt()} EGP',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusActions(order, currentStatus),
        ],
      ),
    );
  }

  Widget _buildStatusActions(OrderEntity order, OrderStatus currentStatus) {
    OrderStatus? nextStatus;

    // Simple 3-status flow: pending → confirmed → arrived
    switch (currentStatus) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.arrived;
        break;
      case OrderStatus.arrived:
        // Final state, no next status
        return const SizedBox();
      case OrderStatus.cancelled:
        // Cancelled orders should not have actions
        return const SizedBox();
    }

    if (nextStatus == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateOrderStatus(order.id, nextStatus!),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _getNextStatusLabel(nextStatus),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        // Only allow cancel when status is pending
        if (currentStatus == OrderStatus.pending) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _cancelOrder(order.id),
            icon: const Icon(Icons.close, color: AppTheme.errorColor, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _cancelOrder(String orderId) async {
    final orderRepo = sl<OrderRepository>();
    await orderRepo.cancelOrder(orderId);
  }

  void _updateOrderStatus(String orderId, OrderStatus status) async {
    final orderRepo = sl<OrderRepository>();
    await orderRepo.updateOrderStatus(
      orderId: orderId,
      newStatus: status,
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }

String _getNextStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.confirmed:
      return 'Confirm Order';
    case OrderStatus.arrived:
      return 'Mark as Arrived';
    case OrderStatus.pending:
      return 'Next';
    case OrderStatus.cancelled:
      return 'Next';
  }
}

_StatusInfo _getStatusInfo(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return _StatusInfo(
        title: 'Pending',
        icon: Icons.hourglass_empty,
        color: AppTheme.warningColor,
      );
    case OrderStatus.confirmed:
      return _StatusInfo(
        title: 'Confirmed',
        icon: Icons.check_circle_outline,
        color: Colors.blue,
      );
    case OrderStatus.arrived:
      return _StatusInfo(
        title: 'Arrived',
        icon: Icons.check_circle,
        color: AppTheme.successColor,
      );
    case OrderStatus.cancelled:
      return _StatusInfo(
        title: 'Cancelled',
        icon: Icons.cancel,
        color: AppTheme.errorColor,
      );
  }
}
}

class _StatusInfo {
  final String title;
  final IconData icon;
  final Color color;

  _StatusInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// Admin dashboard
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const PageLoading();
        }

        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s Orders',
                        '${state.totalOrders}',
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Revenue',
                        '${state.totalOrdersAmount.toInt()} EGP',
                        Icons.attach_money,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '${state.pendingOrders}',
                        Icons.hourglass_empty,
                        AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        '${state.completedOrders}',
                        Icons.check_circle,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin menu management
class AdminMenuManagement extends StatelessWidget {
  const AdminMenuManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Menu Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
