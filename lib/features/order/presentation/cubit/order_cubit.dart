import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../session/domain/repositories/session_repository.dart';

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
  final SessionRepository _sessionRepository;
  StreamSubscription? _orderSubscription;

  OrderCubit(this._orderRepository, this._sessionRepository)
      : super(OrderInitial());

  void loadUserOrder(String userId) async {
    emit(OrderLoading());

    try {
      final session = await _sessionRepository.getCurrentSession();
      if (session == null) {
        emit(const OrderLoaded());
        return;
      }

      final lastOrder = await _orderRepository.getLastUserOrder(userId);

      _orderSubscription?.cancel();
      _orderSubscription = _orderRepository
          .getUserOrderStream(session.id, userId)
          .listen(
        (order) {
          emit(OrderLoaded(currentOrder: order, lastOrder: lastOrder));
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
    required List<MenuItemEntity> menuItems,
    required Map<String, int> selectedQuantities,
  }) async {
    if (selectedQuantities.isEmpty) {
      emit(const OrderError('No items selected'));
      return;
    }

    emit(OrderSubmitting());

    try {
      // Check if session is still open
      final session = await _sessionRepository.getCurrentSession();
      if (session == null || !session.canOrder) {
        emit(const OrderError('Session is closed'));
        return;
      }

      // Check if user already has an order
      final existingOrder = await _orderRepository.getUserOrder(sessionId, userId);
      if (existingOrder != null && !existingOrder.isCancelled) {
        emit(const OrderError('You already have an order'));
        return;
      }

      // Create order items with snapshot of prices
      final orderItems = <OrderItemEntity>[];
      double totalPrice = 0;

      for (final entry in selectedQuantities.entries) {
        final menuItem = menuItems.firstWhere(
          (item) => item.id == entry.key,
          orElse: () => throw Exception('Menu item not found'),
        );

        orderItems.add(OrderItemEntity(
          id: '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
          productId: menuItem.id,
          nameAr: menuItem.name,
          nameEn: menuItem.name,
          basePrice: menuItem.price,
          quantity: entry.value,
        ));

        totalPrice += menuItem.price * entry.value;
      }

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
      // Check if session is still open
      final session = await _sessionRepository.getCurrentSession();
      if (session == null || !session.canOrder) {
        emit(const OrderError('Session is closed'));
        return;
      }

      // Check if user already has an order
      final existingOrder = await _orderRepository.getUserOrder(sessionId, userId);
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
