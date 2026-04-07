import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final OrderEntity? currentOrder;
  final OrderEntity? lastOrder;

  const OrderLoaded({
    this.currentOrder,
    this.lastOrder,
  });

  @override
  List<Object?> get props => [currentOrder, lastOrder];
}

class OrderSubmitting extends OrderState {}

class OrderSubmitted extends OrderState {
  final OrderEntity order;

  const OrderSubmitted(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _orderSubscription;

  OrderCubit(this._orderRepository)
      : super(OrderInitial());

  void loadUserOrder(String userId) async {
    emit(OrderLoading());

    try {
      final lastOrder = await _orderRepository.getLastUserOrder(userId);

      // Load user's active orders
      _orderSubscription?.cancel();
      _orderSubscription = _orderRepository
          .streamUserActiveOrders(userId)
          .listen(
        (orders) {
          // Get the first pending order if any
          final currentOrder = orders.isNotEmpty ? orders.first : null;
          emit(OrderLoaded(currentOrder: currentOrder, lastOrder: lastOrder));
        },
        onError: (error) {
          emit(OrderError(error.toString()));
        },
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> submitOrder({
    required String sessionId,
    required String userId,
    required String userName,
    required Map<String, int> selectedQuantities,
  }) async {
    if (selectedQuantities.isEmpty) {
      emit(const OrderError('No items selected'));
      return;
    }

    emit(OrderSubmitting());

    try {
      // Check if user already has a pending order
      final existingOrder = await _orderRepository.getUserPendingOrder(userId);
      if (existingOrder != null && !existingOrder.isCancelled) {
        emit(const OrderError('You already have an order'));
        return;
      }

      // Create order items with snapshot of prices
      final orderItems = <OrderItemEntity>[];
      double totalPrice = 0;





      final order = OrderEntity(
        id: const Uuid().v4(),
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        userId: userId,
        userName: userName,
        restaurantId: '',
        restaurantNameAr: '',
        restaurantNameEn: '',
        // branchId: '',
        // branchNameAr: '',
        // branchNameEn: '',
        items: orderItems,
        subtotal: totalPrice,
        total: totalPrice,
        isPaid: false,
        isCancelled: false,
        createdAt: DateTime.now(),
      );

      final createdOrder = await _orderRepository.createOrder(order);
      emit(OrderSubmitted(createdOrder));

      // Reload user order
      loadUserOrder(userId);
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> repeatLastOrder({
    required String sessionId,
    required String userId,
    required String userName,
    required OrderEntity lastOrder,
  }) async {
    emit(OrderSubmitting());

    try {
      // Check if user already has a pending order
      final existingOrder = await _orderRepository.getUserPendingOrder(userId);
      if (existingOrder != null && !existingOrder.isCancelled) {
        emit(const OrderError('You already have an order'));
        return;
      }

      final order = OrderEntity(
        id: const Uuid().v4(),
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        userId: userId,
        userName: userName,
        restaurantId: lastOrder.restaurantId,
        restaurantNameAr: lastOrder.restaurantNameAr,
        restaurantNameEn: lastOrder.restaurantNameEn,
        // branchId: lastOrder.branchId,
        // branchNameAr: lastOrder.branchNameAr,
        // branchNameEn: lastOrder.branchNameEn,
        items: lastOrder.items,
        subtotal: lastOrder.subtotal,
        total: lastOrder.total,
        isPaid: false,
        isCancelled: false,
        createdAt: DateTime.now(),
      );

      final createdOrder = await _orderRepository.createOrder(order);
      emit(OrderSubmitted(createdOrder));

      // Reload user order
      loadUserOrder(userId);
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  OrderEntity? get currentOrder {
    final state = this.state;
    if (state is OrderLoaded) {
      return state.currentOrder;
    }
    return null;
  }

  OrderEntity? get lastOrder {
    final state = this.state;
    if (state is OrderLoaded) {
      return state.lastOrder;
    }
    return null;
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
