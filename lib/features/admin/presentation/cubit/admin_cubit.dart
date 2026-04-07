import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/repositories/order_repository.dart';

// States
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<OrderEntity> orders;
  final Map<String, int> aggregatedItems;
  final double totalOrdersAmount;

  const AdminLoaded({
    this.orders = const [],
    this.aggregatedItems = const {},
    this.totalOrdersAmount = 0,
  });

  @override
  List<Object?> get props => [orders, aggregatedItems, totalOrdersAmount];

  AdminLoaded copyWith({
    List<OrderEntity>? orders,
    Map<String, int>? aggregatedItems,
    double? totalOrdersAmount,
  }) {
    return AdminLoaded(
      orders: orders ?? this.orders,
      aggregatedItems: aggregatedItems ?? this.aggregatedItems,
      totalOrdersAmount: totalOrdersAmount ?? this.totalOrdersAmount,
    );
  }

  int get totalOrders => orders.where((o) => !o.isCancelled).length;
  int get paidOrders => orders.where((o) => o.isPaid && !o.isCancelled).length;
  int get unpaidOrders => orders.where((o) => !o.isPaid && !o.isCancelled).length;
  int get cancelledOrders => orders.where((o) => o.isCancelled).length;
  int get pendingOrders => orders.where((o) => o.status == OrderStatus.pending).length;
  int get completedOrders => orders.where((o) => o.status == OrderStatus.arrived).length;

  double get totalPaid => orders
      .where((o) => o.isPaid && !o.isCancelled)
      .fold(0, (sum, o) => sum + o.totalPrice);

  double get totalUnpaid => orders
      .where((o) => !o.isPaid && !o.isCancelled)
      .fold(0, (sum, o) => sum + o.totalPrice);
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminCubit extends Cubit<AdminState> {
  final OrderRepository _orderRepository;

  StreamSubscription? _ordersSubscription;

  AdminCubit(this._orderRepository) : super(AdminInitial());

  void loadAdminData() {
    emit(AdminLoading());

    // Load all active orders (no session filtering needed)
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepository
        .streamOrdersByBranch('') // TODO: Filter by branch when branch context is available
        .listen(
      (orders) {
        final aggregated = _calculateAggregation(orders);
        final totalAmount = orders
            .where((o) => !o.isCancelled)
            .fold(0.0, (sum, o) => sum + o.totalPrice);

        emit(AdminLoaded(
          orders: orders,
          aggregatedItems: aggregated,
          totalOrdersAmount: totalAmount,
        ));
      },
      onError: (error) {
        emit(AdminError(error.toString()));
      },
    );
  }

  Map<String, int> _calculateAggregation(List<OrderEntity> orders) {
    final Map<String, int> aggregated = {};

    for (final order in orders) {
      if (order.isCancelled) continue;
      for (final item in order.items) {
        aggregated[item.name] = (aggregated[item.name] ?? 0) + item.quantity;
      }
    }

    return aggregated;
  }

  Future<void> markOrderPaid(String orderId) async {
    try {
      await _orderRepository.markOrderPaid(orderId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _orderRepository.cancelOrder(orderId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final order = await _orderRepository.getOrderById(orderId);
      if (order != null) {
        await _orderRepository.updateOrder(order.copyWith(status: status));
      }
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
