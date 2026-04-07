import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../features/order/domain/entities/order_entity.dart';
import '../../features/order/domain/repositories/order_repository.dart';

/// State for managing pending order context when adding items
class PendingOrderState extends Equatable {
  final OrderEntity? pendingOrder;
  final bool isAddingToExisting;

  const PendingOrderState({
    this.pendingOrder,
    this.isAddingToExisting = false,
  });

  @override
  List<Object?> get props => [pendingOrder, isAddingToExisting];

  PendingOrderState copyWith({
    OrderEntity? pendingOrder,
    bool? isAddingToExisting,
  }) {
    return PendingOrderState(
      pendingOrder: pendingOrder ?? this.pendingOrder,
      isAddingToExisting: isAddingToExisting ?? this.isAddingToExisting,
    );
  }
}

/// Cubit to manage pending order context across navigation
class PendingOrderCubit extends Cubit<PendingOrderState> {
  final OrderRepository _orderRepository;

  PendingOrderCubit(this._orderRepository) : super(const PendingOrderState());

  /// Set pending order context for adding items
  void setPendingOrder(OrderEntity order) {
    emit(PendingOrderState(
      pendingOrder: order,
      isAddingToExisting: true,
    ));
  }

  /// Clear pending order context
  void clearPendingOrder() {
    emit(const PendingOrderState());
  }

  /// Check and load user's pending order
  Future<void> loadUserPendingOrder(String userId) async {
    try {
      final pendingOrder = await _orderRepository.getUserPendingOrder(userId);
      if (pendingOrder != null) {
        emit(PendingOrderState(
          pendingOrder: pendingOrder,
          isAddingToExisting: false,
        ));
      } else {
        emit(const PendingOrderState());
      }
    } catch (e) {
      emit(const PendingOrderState());
    }
  }
}
