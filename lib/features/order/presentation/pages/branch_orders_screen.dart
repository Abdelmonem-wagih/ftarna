import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../widgets/admin_order_card.dart';

class BranchOrdersScreen extends StatefulWidget {
  final String branchId;
  final String branchName;

  const BranchOrdersScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<BranchOrdersScreen> createState() => _BranchOrdersScreenState();
}

class _BranchOrdersScreenState extends State<BranchOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _ordersSubscription;
  List<OrderEntity> _orders = [];
  bool _isLoading = true;

  final _statusFilters = [
    [OrderStatus.pending, OrderStatus.confirmed],
    // [OrderStatus.preparing],
    // [OrderStatus.ready, OrderStatus.outForDelivery],
    [OrderStatus.arrived],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _subscribeToOrders();
  }

  void _subscribeToOrders() {
    final orderRepo = sl<OrderRepository>();
    _ordersSubscription = orderRepo
        .streamBranchOrders(
          branchId: widget.branchId,
          statuses: [
            OrderStatus.pending,
            OrderStatus.confirmed,
            // OrderStatus.preparing,
            // OrderStatus.ready,
            // OrderStatus.outForDelivery,
            OrderStatus.arrived,
          ],
        )
        .listen(
      (orders) {
        setState(() {
          _orders = orders;
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
    _tabController.dispose();
    _ordersSubscription?.cancel();
    super.dispose();
  }

  List<OrderEntity> _getFilteredOrders(List<OrderStatus> statuses) {
    return _orders.where((o) => statuses.contains(o.status)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branchName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _subscribeToOrders();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            _buildTab('New', _getFilteredOrders(_statusFilters[0]).length),
            _buildTab('Preparing', _getFilteredOrders(_statusFilters[1]).length),
            _buildTab('Ready', _getFilteredOrders(_statusFilters[2]).length),
            _buildTab('Completed', _getFilteredOrders(_statusFilters[3]).length),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_statusFilters[0]),
                _buildOrderList(_statusFilters[1]),
                _buildOrderList(_statusFilters[2]),
                _buildOrderList(_statusFilters[3]),
              ],
            ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderStatus> statuses) {
    final orders = _getFilteredOrders(statuses);
    final locale = Localizations.localeOf(context).languageCode;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _subscribeToOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminOrderCard(
              order: order,
              locale: locale,
              onStatusChange: (newStatus) => _updateOrderStatus(order, newStatus),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateOrderStatus(
    OrderEntity order,
    OrderStatus newStatus,
  ) async {
    try {
      final authState = context.read<AuthCubit>().state;
      String? updatedBy;
      if (authState is AuthAuthenticated) {
        updatedBy = authState.user.id;
      }

      final orderRepo = sl<OrderRepository>();
      await orderRepo.updateOrderStatus(
        orderId: order.id,
        newStatus: newStatus,
        updatedBy: updatedBy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order updated to ${newStatus.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
