import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

/// Notification types
enum NotificationType {
  orderPlaced,
  orderConfirmed,
  orderPreparing,
  orderReady,
  orderOutForDelivery,
  orderDelivered,
  orderCancelled,
  newPromotion,
  general,
}

/// Notification payload
class NotificationPayload {
  final NotificationType type;
  final String? orderId;
  final String? restaurantId;
  final String? branchId;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.type,
    this.orderId,
    this.restaurantId,
    this.branchId,
    this.data = const {},
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return NotificationPayload(
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      orderId: data['orderId'],
      restaurantId: data['restaurantId'],
      branchId: data['branchId'],
      data: data,
    );
  }

  Map<String, String> toMap() {
    return {
      'type': type.name,
      if (orderId != null) 'orderId': orderId!,
      if (restaurantId != null) 'restaurantId': restaurantId!,
      if (branchId != null) 'branchId': branchId!,
      'data': json.encode(data),
    };
  }
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore? _firestore;

  final _notificationController = StreamController<NotificationPayload>.broadcast();
  String? _currentUserId;
  String? _currentBranchId;

  NotificationService(this._messaging, [this._firestore]);

  /// Stream of notification payloads
  Stream<NotificationPayload> get notificationStream => _notificationController.stream;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // Subscribe to topics
    await _messaging.subscribeToTopic('all_users');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);
  }

  /// Set current user for token management
  Future<void> setCurrentUser(String userId) async {
    _currentUserId = userId;
    await _updateUserToken(userId);
  }

  /// Set current branch for admin notifications
  Future<void> setCurrentBranch(String branchId) async {
    // Unsubscribe from previous branch
    if (_currentBranchId != null) {
      await unsubscribeFromTopic('branch_${_currentBranchId}_orders');
    }

    _currentBranchId = branchId;
    await subscribeToTopic('branch_${branchId}_orders');
  }

  /// Subscribe to restaurant notifications
  Future<void> subscribeToRestaurant(String restaurantId) async {
    await subscribeToTopic('restaurant_$restaurantId');
  }

  /// Unsubscribe from restaurant notifications
  Future<void> unsubscribeFromRestaurant(String restaurantId) async {
    await unsubscribeFromTopic('restaurant_$restaurantId');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');
    }

    final payload = NotificationPayload.fromRemoteMessage(message);
    _notificationController.add(payload);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    debugPrint('Message data: ${message.data}');

    final payload = NotificationPayload.fromRemoteMessage(message);
    _notificationController.add(payload);
  }

  void _handleTokenRefresh(String token) async {
    debugPrint('FCM Token refreshed: $token');
    if (_currentUserId != null) {
      await _updateUserToken(_currentUserId!);
    }
  }

  Future<void> _updateUserToken(String userId) async {
    if (_firestore == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore!.collection(FirestoreCollections.users).doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Clear user session (on logout)
  Future<void> clearUserSession() async {
    if (_currentUserId != null && _firestore != null) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore!
            .collection(FirestoreCollections.users)
            .doc(_currentUserId)
            .update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    }

    if (_currentBranchId != null) {
      await unsubscribeFromTopic('branch_${_currentBranchId}_orders');
    }

    _currentUserId = null;
    _currentBranchId = null;
  }

  /// Save notification to Firestore
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    if (_firestore == null) return;

    await _firestore!.collection(FirestoreCollections.notifications).add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    if (_firestore == null) {
      return Stream.value([]);
    }

    return _firestore!
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_firestore == null) return;

    await _firestore!
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    if (_firestore == null) return;

    final batch = _firestore!.batch();
    final snapshot = await _firestore!
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  void dispose() {
    _notificationController.close();
  }
}
