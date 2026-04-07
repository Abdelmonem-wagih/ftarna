import '../../../../core/utils/constants.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  // Legacy methods for backward compatibility
  Stream<List<OrderEntity>> getSessionOrdersStream(String sessionId);
  Stream<OrderEntity?> getUserOrderStream(String sessionId, String userId);
  Future<List<OrderEntity>> getSessionOrders(String sessionId);
  Future<OrderEntity?> getUserOrder(String sessionId, String userId);
  Future<OrderEntity?> getLastUserOrder(String userId);
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<void> updateOrder(OrderEntity order);
  Future<void> markOrderPaid(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> deleteOrder(String orderId);
  Future<Map<String, int>> getAggregatedItems(String sessionId);

  // ========== Multi-tenant Order Management ==========

  /// Get order by ID
  Future<OrderEntity?> getOrderById(String orderId);

  /// Get orders for a user
  Future<List<OrderEntity>> getUserOrders({
    required String userId,
    int? limit,
    String? lastOrderId,
  });

  /// Get active orders for a user
  Future<List<OrderEntity>> getActiveUserOrders(String userId);

  /// Get user's pending order (if any)
  Future<OrderEntity?> getUserPendingOrder(String userId);

  /// Get orders for a branch (admin view)
  Future<List<OrderEntity>> getBranchOrders({
    required String branchId,
    OrderStatus? status,
    int? limit,
    String? lastOrderId,
  });

  /// Get orders for a restaurant (admin view)
  Future<List<OrderEntity>> getRestaurantOrders({
    required String restaurantId,
    OrderStatus? status,
    int? limit,
    String? lastOrderId,
  });

  /// Stream orders for a branch (real-time for admin)
  Stream<List<OrderEntity>> streamBranchOrders({
    required String branchId,
    List<OrderStatus>? statuses,
  });

  /// Stream orders by branch (alias for streamBranchOrders)
  Stream<List<OrderEntity>> streamOrdersByBranch(String branchId);

  /// Stream orders for a restaurant (real-time for admin)
  Stream<List<OrderEntity>> streamRestaurantOrders({
    required String restaurantId,
    List<OrderStatus>? statuses,
  });

  /// Stream active orders for a user
  Stream<List<OrderEntity>> streamUserActiveOrders(String userId);

  /// Stream single order
  Stream<OrderEntity?> streamOrder(String orderId);

  /// Create order from cart
  Future<OrderEntity> createOrderFromCart({
    required String userId,
    required String userName,
    String? userPhone,
    required String restaurantId,
    required String restaurantNameAr,
    required String restaurantNameEn,
    // required String branchId,
    // required String branchNameAr,
    // required String branchNameEn,
    required List<OrderItemEntity> items,
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    String? discountCode,
    String? offerId,
    DeliveryInfo? deliveryInfo,
    String? paymentMethod,
    String? notes,
  });

  /// Add items to pending order
  Future<OrderEntity> addItemsToPendingOrder({
    required String orderId,
    required List<OrderItemEntity> items,
  });

  /// Update order status
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? note,
    String? updatedBy,
  });

  /// Mark order as paid
  Future<void> markAsPaid(String orderId);

  /// Cancel order with reason
  Future<void> cancelOrderWithReason(String orderId, String? reason);

  /// Get order statistics for a branch
  Future<Map<String, dynamic>> getBranchOrderStats({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Generate order number
  String generateOrderNumber();

  /// Batch update order status for multiple orders
  Future<void> batchUpdateOrderStatus({
    required List<String> orderIds,
    required OrderStatus newStatus,
    String? note,
    String? updatedBy,
  });
}
