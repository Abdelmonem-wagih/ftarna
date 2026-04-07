import 'package:equatable/equatable.dart';
import '../../../order/domain/entities/order_entity.dart';

/// Summary of all orders for a specific user
class UserOrdersSummary extends Equatable {
  final String userId;
  final String userName;
  final String? userPhone;
  final List<OrderEntity> orders;
  final double totalAmount;
  final double paidAmount;
  final double unpaidAmount;
  final int totalOrders;
  final int paidOrders;
  final int unpaidOrders;

  const UserOrdersSummary({
    required this.userId,
    required this.userName,
    this.userPhone,
    required this.orders,
    required this.totalAmount,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.totalOrders,
    required this.paidOrders,
    required this.unpaidOrders,
  });

  /// Check if user has any unpaid orders
  bool get hasUnpaidOrders => unpaidOrders > 0;

  /// Get only unpaid orders
  List<OrderEntity> get unpaidOrdersList => orders.where((o) => !o.isPaid && !o.isCancelled).toList();

  /// Get only paid orders
  List<OrderEntity> get paidOrdersList => orders.where((o) => o.isPaid && !o.isCancelled).toList();

  /// Payment completion percentage
  double get paymentCompletionPercentage {
    if (totalAmount == 0) return 0;
    return (paidAmount / totalAmount) * 100;
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        userPhone,
        orders,
        totalAmount,
        paidAmount,
        unpaidAmount,
        totalOrders,
        paidOrders,
        unpaidOrders,
      ];

  factory UserOrdersSummary.fromOrders({
    required String userId,
    required String userName,
    String? userPhone,
    required List<OrderEntity> orders,
  }) {
    final validOrders = orders.where((o) => !o.isCancelled).toList();
    final paidOrdersList = validOrders.where((o) => o.isPaid).toList();
    final unpaidOrdersList = validOrders.where((o) => !o.isPaid).toList();

    return UserOrdersSummary(
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      orders: validOrders,
      totalAmount: validOrders.fold(0.0, (sum, o) => sum + o.total),
      paidAmount: paidOrdersList.fold(0.0, (sum, o) => sum + o.total),
      unpaidAmount: unpaidOrdersList.fold(0.0, (sum, o) => sum + o.total),
      totalOrders: validOrders.length,
      paidOrders: paidOrdersList.length,
      unpaidOrders: unpaidOrdersList.length,
    );
  }
}
