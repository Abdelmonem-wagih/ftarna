import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/constants.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../domain/entities/aggregated_order_item.dart';
import '../../domain/entities/user_orders_summary.dart';

// ========================
// STATES
// ========================

abstract class RestaurantOrdersState extends Equatable {
  const RestaurantOrdersState();

  @override
  List<Object?> get props => [];
}

class RestaurantOrdersInitial extends RestaurantOrdersState {}

class RestaurantOrdersLoading extends RestaurantOrdersState {}

class RestaurantOrdersLoaded extends RestaurantOrdersState {
  final List<OrderEntity> allOrders;
  final List<AggregatedOrderItem> aggregatedItems;
  final List<UserOrdersSummary> usersSummaries;
  final double totalRevenue;
  final double totalPaid;
  final double totalUnpaid;

  const RestaurantOrdersLoaded({
    required this.allOrders,
    required this.aggregatedItems,
    required this.usersSummaries,
    required this.totalRevenue,
    required this.totalPaid,
    required this.totalUnpaid,
  });

  @override
  List<Object?> get props => [
        allOrders,
        aggregatedItems,
        usersSummaries,
        totalRevenue,
        totalPaid,
        totalUnpaid,
      ];

  /// Get users with unpaid orders only
  List<UserOrdersSummary> get usersWithUnpaidOrders =>
      usersSummaries.where((u) => u.hasUnpaidOrders).toList()
        ..sort((a, b) => b.unpaidAmount.compareTo(a.unpaidAmount));

  /// Total number of orders
  int get totalOrders => allOrders.where((o) => !o.isCancelled).length;

  /// Total items across all orders
  int get totalItems => aggregatedItems.fold(0, (sum, item) => sum + item.totalQuantity);

  /// Get the global status (most common status among active orders)
  OrderStatus? get globalStatus {
    final activeOrders = allOrders.where((o) => !o.isCancelled && o.status != OrderStatus.arrived).toList();
    if (activeOrders.isEmpty) return null;

    // Find the most common status
    final statusCounts = <OrderStatus, int>{};
    for (final order in activeOrders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }

    // Return the status with highest count
    OrderStatus? dominantStatus;
    int maxCount = 0;
    for (final entry in statusCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantStatus = entry.key;
      }
    }

    return dominantStatus;
  }

  /// Get next status for batch update
  OrderStatus? get nextGlobalStatus {
    return globalStatus?.nextStatus;
  }

  /// Check if all active orders have the same status
  bool get hasUniformStatus {
    final activeOrders = allOrders.where((o) => !o.isCancelled && o.status != OrderStatus.arrived).toList();
    if (activeOrders.isEmpty) return false;

    final firstStatus = activeOrders.first.status;
    return activeOrders.every((o) => o.status == firstStatus);
  }
}

class RestaurantOrdersError extends RestaurantOrdersState {
  final String message;

  const RestaurantOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

// ========================
// CUBIT
// ========================

class RestaurantOrdersCubit extends Cubit<RestaurantOrdersState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _ordersSubscription;

  RestaurantOrdersCubit(this._orderRepository) : super(RestaurantOrdersInitial());

  /// Load orders for a specific restaurant (real-time)
  void loadRestaurantOrders(String restaurantId) {
    emit(RestaurantOrdersLoading());

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepository
        .streamRestaurantOrders(restaurantId: restaurantId)
        .listen(
          _handleOrdersUpdate,
          onError: (error) {
            emit(RestaurantOrdersError(error.toString()));
          },
        );
  }

  void _handleOrdersUpdate(List<OrderEntity> orders) {
    try {
      // Filter out cancelled orders for calculations
      final validOrders = orders.where((o) => !o.isCancelled).toList();

      // 1. Aggregate items across all orders
      final aggregatedItems = _aggregateItems(validOrders);

      // 2. Group orders by user
      final usersSummaries = _groupOrdersByUser(validOrders);

      // 3. Calculate totals
      final totalRevenue = validOrders.fold(0.0, (sum, o) => sum + o.total);
      final totalPaid = validOrders.where((o) => o.isPaid).fold(0.0, (sum, o) => sum + o.total);
      final totalUnpaid = validOrders.where((o) => !o.isPaid).fold(0.0, (sum, o) => sum + o.total);

      emit(RestaurantOrdersLoaded(
        allOrders: orders,
        aggregatedItems: aggregatedItems,
        usersSummaries: usersSummaries,
        totalRevenue: totalRevenue,
        totalPaid: totalPaid,
        totalUnpaid: totalUnpaid,
      ));
    } catch (e) {
      emit(RestaurantOrdersError(e.toString()));
    }
  }

  /// Aggregate all items across orders
  List<AggregatedOrderItem> _aggregateItems(List<OrderEntity> orders) {
    final Map<String, AggregatedOrderItem> itemsMap = {};

    for (final order in orders) {
      for (final item in order.items) {
        final key = item.productId;

        if (itemsMap.containsKey(key)) {
          final existing = itemsMap[key]!;
          itemsMap[key] = AggregatedOrderItem(
            productId: existing.productId,
            nameAr: existing.nameAr,
            nameEn: existing.nameEn,
            imageUrl: existing.imageUrl,
            totalQuantity: existing.totalQuantity + item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: existing.totalPrice + item.totalPrice,
          );
        } else {
          itemsMap[key] = AggregatedOrderItem(
            productId: item.productId,
            nameAr: item.nameAr,
            nameEn: item.nameEn,
            imageUrl: item.imageUrl,
            totalQuantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
          );
        }
      }
    }

    // Sort by quantity descending
    final items = itemsMap.values.toList()
      ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    return items;
  }

  /// Group orders by user and create summaries
  List<UserOrdersSummary> _groupOrdersByUser(List<OrderEntity> orders) {
    final Map<String, List<OrderEntity>> ordersByUser = {};

    for (final order in orders) {
      if (!ordersByUser.containsKey(order.userId)) {
        ordersByUser[order.userId] = [];
      }
      ordersByUser[order.userId]!.add(order);
    }

    final summaries = <UserOrdersSummary>[];

    for (final entry in ordersByUser.entries) {
      final userOrders = entry.value;
      if (userOrders.isEmpty) continue;

      final firstOrder = userOrders.first;
      summaries.add(
        UserOrdersSummary.fromOrders(
          userId: entry.key,
          userName: firstOrder.userName,
          userPhone: firstOrder.userPhone,
          orders: userOrders,
        ),
      );
    }

    // Sort by total amount descending
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }

  /// Mark a specific order as paid
  Future<void> markOrderAsPaid(String orderId) async {
    try {
      await _orderRepository.markOrderPaid(orderId);
      // Stream will automatically update
    } catch (e) {
      emit(RestaurantOrdersError('Failed to mark order as paid: $e'));
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.deleteOrder(orderId);
      // Stream will automatically update
    } catch (e) {
      emit(RestaurantOrdersError('Failed to delete order: $e'));
    }
  }

  /// Batch update all active orders to next status
  Future<void> updateAllOrdersToNextStatus({String? updatedBy}) async {
    final currentState = state;
    if (currentState is! RestaurantOrdersLoaded) return;

    final nextStatus = currentState.nextGlobalStatus;
    if (nextStatus == null) return;

    // Get all active orders that can be updated
    final orderIdsToUpdate = currentState.allOrders
        .where((o) => !o.isCancelled && o.status != OrderStatus.arrived && o.status.nextStatus != null)
        .map((o) => o.id)
        .toList();

    if (orderIdsToUpdate.isEmpty) return;

    try {
      await _orderRepository.batchUpdateOrderStatus(
        orderIds: orderIdsToUpdate,
        newStatus: nextStatus,
        note: 'Batch update by admin',
        updatedBy: updatedBy,
      );
      // Stream will automatically update with new statuses
    } catch (e) {
      emit(RestaurantOrdersError('Failed to update orders: $e'));
      // Re-emit the loaded state after error
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
