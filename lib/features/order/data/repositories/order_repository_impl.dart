import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/constants.dart';
import '../../../../core/services/order_notification_service.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  // ========== Legacy Methods ==========

  @override
  Stream<List<OrderEntity>> getSessionOrdersStream(String sessionId) {
    return _ordersCollection
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Stream<OrderEntity?> getUserOrderStream(String sessionId, String userId) {
    return _ordersCollection
        .where('sessionId', isEqualTo: sessionId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return OrderModel.fromFirestore(snapshot.docs.first).toEntity();
    });
  }

  @override
  Future<List<OrderEntity>> getSessionOrders(String sessionId) async {
    final snapshot = await _ordersCollection
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt')
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<OrderEntity?> getUserOrder(String sessionId, String userId) async {
    final snapshot = await _ordersCollection
        .where('sessionId', isEqualTo: sessionId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return OrderModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<OrderEntity?> getLastUserOrder(String userId) async {
    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('isCancelled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return OrderModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final docRef = await _ordersCollection.add(OrderModel.toJson(order));
    return order.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateOrder(OrderEntity order) async {
    await _ordersCollection.doc(order.id).update(OrderModel.toJson(order));
  }

  @override
  Future<void> markOrderPaid(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'isPaid': true,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'isCancelled': true,
      'status': OrderStatus.cancelled.name,
    });
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
  }

  @override
  Future<Map<String, int>> getAggregatedItems(String sessionId) async {
    final orders = await getSessionOrders(sessionId);
    final Map<String, int> aggregated = {};

    for (final order in orders) {
      if (order.isCancelled) continue;
      for (final item in order.items) {
        final key = item.name;
        aggregated[key] = (aggregated[key] ?? 0) + item.quantity;
      }
    }

    return aggregated;
  }

  // ========== Multi-tenant Methods ==========

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<List<OrderEntity>> getUserOrders({
    required String userId,
    int? limit,
    String? lastOrderId,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<OrderEntity>> getActiveUserOrders(String userId) async {
    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereNotIn: [
          OrderStatus.arrived.name,
          OrderStatus.cancelled.name,
        ])
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<OrderEntity?> getUserPendingOrder(String userId) async {
    final snapshot = await _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: OrderStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return OrderModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<List<OrderEntity>> getBranchOrders({
    required String branchId,
    OrderStatus? status,
    int? limit,
    String? lastOrderId,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection
        .where('branchId', isEqualTo: branchId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<OrderEntity>> getRestaurantOrders({
    required String restaurantId,
    OrderStatus? status,
    int? limit,
    String? lastOrderId,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Stream<List<OrderEntity>> streamBranchOrders({
    required String branchId,
    List<OrderStatus>? statuses,
  }) {
    Query<Map<String, dynamic>> query = _ordersCollection
        .where('branchId', isEqualTo: branchId)
        .orderBy('createdAt', descending: true);

    if (statuses != null && statuses.isNotEmpty) {
      query = query.where(
        'status',
        whereIn: statuses.map((s) => s.name).toList(),
      );
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Stream<List<OrderEntity>> streamOrdersByBranch(String branchId) {
    return streamBranchOrders(branchId: branchId);
  }

  @override
  Stream<List<OrderEntity>> streamRestaurantOrders({
    required String restaurantId,
    List<OrderStatus>? statuses,
  }) {
    print('🔍 OrderRepo - Streaming orders for restaurantId: $restaurantId');

    Query<Map<String, dynamic>> query = _ordersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true);

    if (statuses != null && statuses.isNotEmpty) {
      query = query.where(
        'status',
        whereIn: statuses.map((s) => s.name).toList(),
      );
    }

    return query.snapshots().map((snapshot) {
      print('📦 OrderRepo - Query returned ${snapshot.docs.length} documents');
      final orders = snapshot.docs
          .map((doc) {
            try {
              final order = OrderModel.fromFirestore(doc).toEntity();
              print('   - Doc ${doc.id}: restaurantId=${doc.data()['restaurantId']}, status=${doc.data()['status']}');
              return order;
            } catch (e) {
              print('❌ OrderRepo - Error parsing doc ${doc.id}: $e');
              return null;
            }
          })
          .whereType<OrderEntity>()
          .toList();
      print('✅ OrderRepo - Successfully parsed ${orders.length} orders');
      return orders;
    });
  }

  @override
  Stream<List<OrderEntity>> streamUserActiveOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereNotIn: [
          OrderStatus.arrived.name,
          OrderStatus.cancelled.name,
        ])
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc).toEntity())
              .toList();
        });
  }

  @override
  Stream<OrderEntity?> streamOrder(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc).toEntity();
    });
  }

  @override
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
  }) async {
    final now = DateTime.now();
    final orderNumber = generateOrderNumber();

    final order = OrderEntity(
      id: '',
      orderNumber: orderNumber,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      restaurantId: restaurantId,
      restaurantNameAr: restaurantNameAr,
      restaurantNameEn: restaurantNameEn,
      // branchId: branchId,
      // branchNameAr: branchNameAr,
      // branchNameEn: branchNameEn,
      items: items,
      status: OrderStatus.pending,
      statusHistory: [
        OrderStatusHistory(
          status: OrderStatus.pending,
          timestamp: now,
          note: 'Order placed',
        ),
      ],
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: subtotal + deliveryFee - discount,
      discountCode: discountCode,
      offerId: offerId,
      deliveryInfo: deliveryInfo,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
    );

    final docRef = await _ordersCollection.add(OrderModel.toJson(order));

    // Increment branch order count
    // await _firestore
    //     .collection(FirestoreCollections.branches)
    //     .doc(branchId)
    //     .update({'totalOrders': FieldValue.increment(1)});

    final createdOrder = order.copyWith(id: docRef.id);

    // Send notification about new order
    try {
      final notificationService = sl<OrderNotificationService>();
      await notificationService.notifyNewOrder(order: createdOrder);
    } catch (e) {
      // Log but don't fail order creation
      print('⚠️ Failed to send new order notification: $e');
    }

    return createdOrder;
  }

  @override
  Future<OrderEntity> addItemsToPendingOrder({
    required String orderId,
    required List<OrderItemEntity> items,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!order.canAddItems) {
      throw Exception('Cannot add items to this order');
    }

    final updatedItems = [...order.items, ...items];
    final newSubtotal = updatedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final newTotal = newSubtotal + order.deliveryFee - order.discount;

    await _ordersCollection.doc(orderId).update({
      'items': updatedItems.map((i) => _orderItemToJson(i)).toList(),
      'subtotal': newSubtotal,
      'total': newTotal,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return order.copyWith(
      items: updatedItems,
      subtotal: newSubtotal,
      total: newTotal,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? note,
    String? updatedBy,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    final now = DateTime.now();
    final newHistoryEntry = OrderStatusHistory(
      status: newStatus,
      timestamp: now,
      note: note,
      updatedBy: updatedBy,
    );

    final updatedHistory = [...order.statusHistory, newHistoryEntry];

    await _ordersCollection.doc(orderId).update({
      'status': newStatus.name,
      'statusHistory': updatedHistory.map((h) => h.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedOrder = order.copyWith(
      status: newStatus,
      statusHistory: updatedHistory,
      updatedAt: now,
    );

    // Send notification about status change
    try {
      final notificationService = sl<OrderNotificationService>();
      await notificationService.notifyOrderStatusChange(
        order: updatedOrder,
        newStatus: newStatus,
      );
    } catch (e) {
      // Log but don't fail status update
      print('⚠️ Failed to send status change notification: $e');
    }

    return updatedOrder;
  }

  @override
  Future<void> markAsPaid(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'isPaid': true,
      'paidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send payment notification
    try {
      final order = await getOrderById(orderId);
      if (order != null) {
        final notificationService = sl<OrderNotificationService>();
        await notificationService.notifyPaymentDone(order: order);
      }
    } catch (e) {
      print('⚠️ Failed to send payment notification: $e');
    }
  }

  @override
  Future<void> cancelOrderWithReason(String orderId, String? reason) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!order.canCancel) {
      throw Exception('Cannot cancel this order');
    }

    final now = DateTime.now();
    final cancelEntry = OrderStatusHistory(
      status: OrderStatus.cancelled,
      timestamp: now,
      note: reason ?? 'Order cancelled',
    );

    final updatedHistory = [...order.statusHistory, cancelEntry];

    await _ordersCollection.doc(orderId).update({
      'status': OrderStatus.cancelled.name,
      'statusHistory': updatedHistory.map((h) => h.toJson()).toList(),
      'isCancelled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>> getBranchOrderStats({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection
        .where('branchId', isEqualTo: branchId);

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    final orders = snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc).toEntity())
        .toList();

    final totalOrders = orders.length;
    final completedOrders = orders.where((o) => o.status == OrderStatus.arrived).length;
    final cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled).length;
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.arrived && o.isPaid)
        .fold(0.0, (sum, o) => sum + o.total);

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
      'completionRate': totalOrders > 0 ? (completedOrders / totalOrders * 100) : 0,
    };
  }

  @override
  String generateOrderNumber() {
    final now = DateTime.now();
    final datePrefix = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = const Uuid().v4().substring(0, 6).toUpperCase();
    return 'ORD-$datePrefix-$randomSuffix';
  }

  @override
  Future<void> batchUpdateOrderStatus({
    required List<String> orderIds,
    required OrderStatus newStatus,
    String? note,
    String? updatedBy,
  }) async {
    if (orderIds.isEmpty) return;

    final batch = _firestore.batch();
    final now = Timestamp.now();

    final newHistoryEntry = OrderStatusHistory(
      status: newStatus,
      timestamp: DateTime.now(),
      note: note,
      updatedBy: updatedBy,
    );

    // Fetch all orders first to get their current history
    final ordersData = await Future.wait(
      orderIds.map((id) => _ordersCollection.doc(id).get()),
    );

    for (final doc in ordersData) {
      if (!doc.exists) continue;

      final orderData = doc.data()!;
      final currentHistory = (orderData['statusHistory'] as List<dynamic>?)
              ?.map((h) => OrderStatusHistory.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [];

      final updatedHistory = [...currentHistory, newHistoryEntry];

      batch.update(doc.reference, {
        'status': newStatus.name,
        'statusHistory': updatedHistory.map((h) => h.toJson()).toList(),
        'updatedAt': now,
      });
    }

    await batch.commit();

    // Send notifications to all users (async, don't wait)
    try {
      final notificationService = sl<OrderNotificationService>();
      for (final orderId in orderIds) {
        final order = await getOrderById(orderId);
        if (order != null) {
          notificationService.notifyOrderStatusChange(
            order: order.copyWith(status: newStatus),
            newStatus: newStatus,
          );
        }
      }
    } catch (e) {
      print('⚠️ Failed to send batch notifications: $e');
    }
  }

  // Helper method
  Map<String, dynamic> _orderItemToJson(OrderItemEntity item) {
    return item.toJson();
  }
}
