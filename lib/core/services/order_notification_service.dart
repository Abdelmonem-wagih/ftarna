import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import '../../features/order/domain/entities/order_entity.dart';

/// Service to handle order-related notifications
class OrderNotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  OrderNotificationService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  /// Send notification when new order is created
  Future<void> notifyNewOrder({
    required OrderEntity order,
  }) async {
    try {
      // Notify admin(s) - You can customize based on restaurant/branch
      await _sendToAdmins(
        title: '🔔 New Order #${order.orderNumber}',
        body: 'New order from ${order.userName} - ${order.items.length} items, ${order.total.toInt()} EGP',
        data: {
          'type': 'new_order',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'restaurantId': order.restaurantId,
        },
        restaurantId: order.restaurantId,
      );

      debugPrint('✅ New order notification sent to admins');
    } catch (e) {
      debugPrint('❌ Error sending new order notification: $e');
    }
  }

  /// Send notification when order status changes
  Future<void> notifyOrderStatusChange({
    required OrderEntity order,
    required OrderStatus newStatus,
  }) async {
    try {
      String title;
      String body;

      switch (newStatus) {
        case OrderStatus.confirmed:
          title = '✅ Order Confirmed #${order.orderNumber}';
          body = 'Your order has been confirmed and is being prepared';
          break;
        case OrderStatus.arrived:
          title = '🎉 Order Arrived #${order.orderNumber}';
          body = 'Your order has arrived! Enjoy your meal!';
          break;
        case OrderStatus.cancelled:
          title = '❌ Order Cancelled #${order.orderNumber}';
          body = 'Your order has been cancelled';
          break;
        default:
          return; // Don't send for pending
      }

      // Send notification to user
      await _sendToUser(
        userId: order.userId,
        title: title,
        body: body,
        data: {
          'type': 'order_status_change',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'status': newStatus.name,
        },
      );

      debugPrint('✅ Order status change notification sent to user ${order.userId}');
    } catch (e) {
      debugPrint('❌ Error sending order status notification: $e');
    }
  }

  /// Send notification when payment is done
  Future<void> notifyPaymentDone({
    required OrderEntity order,
  }) async {
    try {
      // Notify user
      await _sendToUser(
        userId: order.userId,
        title: '💰 Payment Received #${order.orderNumber}',
        body: 'Your payment of ${order.total.toInt()} EGP has been received',
        data: {
          'type': 'payment_done',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'amount': order.total.toString(),
        },
      );

      // Notify admin
      await _sendToAdmins(
        title: '💰 Payment Received #${order.orderNumber}',
        body: '${order.userName} paid ${order.total.toInt()} EGP',
        data: {
          'type': 'payment_done',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'amount': order.total.toString(),
        },
        restaurantId: order.restaurantId,
      );

      debugPrint('✅ Payment notification sent');
    } catch (e) {
      debugPrint('❌ Error sending payment notification: $e');
    }
  }

  /// Send push notification to specific user
  Future<void> _sendToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Get user's FCM tokens
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data();
      final tokens = userData?['fcmTokens'] as List<dynamic>?;

      if (tokens == null || tokens.isEmpty) {
        debugPrint('⚠️ User $userId has no FCM tokens');
        return;
      }

      // Save notification to Firestore
      await _saveNotificationToFirestore(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );

      // Send FCM notification using Cloud Functions or direct HTTP API
      // Note: For production, use Cloud Functions or your backend
      // This is a placeholder - implement based on your setup
      debugPrint('📤 Would send FCM to user $userId tokens: $tokens');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');

      // You can use Firebase Cloud Messaging HTTP API or Cloud Functions here
      // For now, we save to Firestore and rely on Firestore triggers
    } catch (e) {
      debugPrint('❌ Error sending notification to user: $e');
    }
  }

  /// Send push notification to admins
  Future<void> _sendToAdmins({
    required String title,
    required String body,
    Map<String, String>? data,
    String? restaurantId,
  }) async {
    try {
      // Query admins
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestoreCollections.users)
          .where('role', whereIn: [
        UserRole.superAdmin.name,
        UserRole.restaurantAdmin.name,
      ]);

      // Filter by restaurant if provided
      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      }

      final admins = await query.get();

      for (final adminDoc in admins.docs) {
        final adminData = adminDoc.data();
        final tokens = adminData['fcmTokens'] as List<dynamic>?;

        if (tokens != null && tokens.isNotEmpty) {
          // Save notification
          await _saveNotificationToFirestore(
            userId: adminDoc.id,
            title: title,
            body: body,
            data: data,
          );

          debugPrint('📤 Would send FCM to admin ${adminDoc.id}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error sending notification to admins: $e');
    }
  }

  /// Save notification to Firestore for persistence
  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      await _firestore.collection(FirestoreCollections.notifications).add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error saving notification to Firestore: $e');
    }
  }
}
