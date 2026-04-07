import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderEntity> _activeOrders = [];
  List<OrderEntity> _pastOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final orderRepo = sl<OrderRepository>();
      final orders = await orderRepo.getUserOrders(userId: authState.user.id);

      setState(() {
        _activeOrders = orders.where((o) => o.isActive).toList();
        _pastOrders = orders.where((o) => !o.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: Text(
          l10n.orders,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const PageLoading()
          : _error != null
              ? AppErrorState.general(
                  description: _error,
                  onRetry: _loadOrders,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(_activeOrders, locale, isActive: true),
                    _buildOrderList(_pastOrders, locale, isActive: false),
                  ],
                ),
    );
  }

  Widget _buildOrderList(
    List<OrderEntity> orders,
    String locale, {
    required bool isActive,
  }) {
    if (orders.isEmpty) {
      return AppEmptyState.noOrders(
        title: isActive ? 'No active orders' : 'No past orders',
        description: isActive
            ? 'Your active orders will appear here'
            : 'Your order history will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: order,
              locale: locale,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(
                      orderId: order.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Order card widget
class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final String locale;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
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
                    fontSize: 15,
                  ),
                ),
                StatusBadge(
                  label: statusInfo.title,
                  color: statusInfo.color,
                  icon: statusInfo.icon,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.getLocalizedRestaurantName(locale),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${order.items.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${order.total.toInt()} EGP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (order.isActive)
                  Row(
                    children: [
                      Text(
                        'Track Order',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
      // case OrderStatus.preparing:
      //   return _StatusInfo(
      //     title: 'Preparing',
      //     icon: Icons.restaurant,
      //     color: Colors.orange,
      //   );
      // case OrderStatus.ready:
      //   return _StatusInfo(
      //     title: 'Ready',
      //     icon: Icons.takeout_dining,
      //     color: Colors.teal,
      //   );
      // case OrderStatus.outForDelivery:
      //   return _StatusInfo(
      //     title: 'On the Way',
      //     icon: Icons.delivery_dining,
      //     color: Colors.indigo,
      //   );
      case OrderStatus.arrived:
        return _StatusInfo(
          title: 'Delivered',
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
