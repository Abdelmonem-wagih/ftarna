import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../session/domain/entities/session_entity.dart';
import '../../../session/domain/repositories/session_repository.dart';

// States
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final SessionEntity? session;
  final List<OrderEntity> orders;
  final Map<String, int> aggregatedItems;
  final double totalOrdersAmount;

  const AdminLoaded({
    this.session,
    this.orders = const [],
    this.aggregatedItems = const {},
    this.totalOrdersAmount = 0,
  });

  @override
  List<Object?> get props => [session, orders, aggregatedItems, totalOrdersAmount];

  AdminLoaded copyWith({
    SessionEntity? session,
    List<OrderEntity>? orders,
    Map<String, int>? aggregatedItems,
    double? totalOrdersAmount,
  }) {
    return AdminLoaded(
      session: session ?? this.session,
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
  final SessionRepository _sessionRepository;
  final OrderRepository _orderRepository;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _ordersSubscription;

  AdminCubit(
    this._sessionRepository,
    this._orderRepository,
  ) : super(AdminInitial());

  void loadAdminData() {
    emit(AdminLoading());

    _sessionSubscription?.cancel();
    _sessionSubscription = _sessionRepository.currentSessionStream.listen(
      (session) {
        _loadOrdersForSession(session);
      },
      onError: (error) {
        emit(AdminError(error.toString()));
      },
    );
  }

  void _loadOrdersForSession(SessionEntity? session) {
    if (session == null) {
      emit(const AdminLoaded());
      return;
    }

    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepository
        .getSessionOrdersStream(session.id)
        .listen(
      (orders) {
        final aggregated = _calculateAggregation(orders);
        final totalAmount = orders
            .where((o) => !o.isCancelled)
            .fold(0.0, (sum, o) => sum + o.totalPrice);

        emit(AdminLoaded(
          session: session,
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

  Future<void> createSession() async {
    try {
      await _sessionRepository.createSession();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> openSession(String sessionId) async {
    try {
      await _sessionRepository.openSession(sessionId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> closeSession(String sessionId) async {
    try {
      await _sessionRepository.closeSession(sessionId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> markDelivered(String sessionId) async {
    try {
      await _sessionRepository.markSessionDelivered(sessionId);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> setDeliveryFee(String sessionId, double fee) async {
    try {
      await _sessionRepository.setDeliveryFee(sessionId, fee);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> setTotalBill(String sessionId, double bill) async {
    try {
      await _sessionRepository.setTotalBill(sessionId, bill);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
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

  SessionEntity? get currentSession {
    final state = this.state;
    if (state is AdminLoaded) {
      return state.session;
    }
    return null;
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _ordersSubscription?.cancel();
    return super.close();
  }
}
