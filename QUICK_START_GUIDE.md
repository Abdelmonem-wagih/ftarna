# 🚀 Quick Start Guide - Order Management System

## For Developers

### Setting Up Notifications

1. **Ensure FCM tokens are collected on login:**
```dart
// In your auth flow after successful login
final token = await FirebaseMessaging.instance.getToken();
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
  'fcmTokens': FieldValue.arrayUnion([token]),
});
```

2. **Initialize NotificationService in main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDependencies(); // This registers all services
  
  // Initialize FCM
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  
  runApp(MyApp());
}
```

3. **Set up Cloud Functions for production FCM (Optional but recommended):**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendOrderNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const userId = notification.userId;
    
    // Get user's FCM tokens
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    const tokens = userDoc.data().fcmTokens || [];
    
    if (tokens.length === 0) return;
    
    // Send notification
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
      tokens: tokens,
    };
    
    await admin.messaging().sendMulticast(message);
  });
```

---

## For Users

### How to Add Items to Pending Order

1. **Place your first order:**
   - Browse restaurants
   - Add items to cart
   - Checkout → Order created (status: pending)

2. **Add more items:**
   - Go to "My Orders"
   - Click on your pending order
   - Click "Add More Items" button
   - Select restaurant (must be same as original order)
   - Add items to cart
   - Checkout → Items added to existing order

3. **What happens:**
   - ✅ Items added to your existing order
   - ✅ Total updated automatically
   - ✅ Order number stays the same
   - ❌ Cannot add items from different restaurant

### Order Status Meanings

| Status | What it means | Can you modify? |
|--------|---------------|-----------------|
| **Pending** 🕐 | Order received, waiting for confirmation | ✅ Yes - Add/remove items, cancel |
| **Confirmed** ✅ | Restaurant preparing your order | ❌ No - Order locked |
| **Arrived** 🎉 | Order completed and delivered | ❌ No - Final state |
| **Cancelled** ❌ | Order was cancelled | ❌ No - Final state |

---

## For Admins

### Managing Orders

#### From Admin Panel:

1. **View Orders by Status:**
   - Pending column (left)
   - Confirmed column (middle)
   - Arrived column (right)

2. **Update Order Status:**

**Pending Orders:**
```
[Confirm Order] button → Changes to Confirmed
[X] button → Cancels order
```

**Confirmed Orders:**
```
[Mark as Arrived] button → Changes to Arrived
```

**Arrived Orders:**
```
No actions (final state)
```

3. **View Order History:**
   - Click on order card
   - See status history with timestamps
   - See all status changes

### Admin Notifications

You'll receive notifications for:
- 🔔 New order created
- 💰 Payment received
- Each notification includes order number and customer name

---

## Troubleshooting

### Issue: Notifications not received

**Solution:**
1. Check FCM token is saved:
```dart
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
    
print('FCM Tokens: ${userDoc.data()['fcmTokens']}');
```

2. Check notification was saved:
```dart
final notifications = await FirebaseFirestore.instance
    .collection('notifications')
    .where('userId', isEqualTo: userId)
    .get();
    
print('Notifications: ${notifications.docs.length}');
```

3. Implement Cloud Functions (see above)

### Issue: "Add More Items" creates new order instead of adding to existing

**Solution:**
1. Check order status is pending:
```dart
if (order.status != OrderStatus.pending) {
  // Cannot add items - order is locked
}
```

2. Check restaurant ID matches:
```dart
if (order.restaurantId != cart.restaurantId) {
  // Cannot add items from different restaurant
  // Should show warning and create new order
}
```

### Issue: Admin cannot change status

**Solution:**
1. Check admin role:
```dart
final user = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
    
print('User role: ${user.data()['role']}');
// Should be: restaurantAdmin, branchAdmin, or superAdmin
```

2. Check status flow is valid:
```
✅ pending → confirmed (OK)
✅ confirmed → arrived (OK)
❌ confirmed → pending (NOT ALLOWED)
❌ arrived → confirmed (NOT ALLOWED)
```

### Issue: Status history not showing

**Solution:**
Status history is automatically tracked when you use:
```dart
await orderRepo.updateOrderStatus(
  orderId: orderId,
  newStatus: newStatus,
  note: 'Optional note',
  updatedBy: adminId, // Optional
);
```

Check Firestore:
```
orders/{orderId}/statusHistory
[
  {
    status: 'pending',
    timestamp: DateTime,
    note: 'Order placed',
  },
  {
    status: 'confirmed',
    timestamp: DateTime,
    note: 'Confirmed by admin',
    updatedBy: 'adminUserId',
  }
]
```

---

## Code Examples

### Check if User Can Modify Order

```dart
if (order.canModify) {
  // Show "Add Items", "Remove Items", "Cancel" buttons
  showEditControls();
} else {
  // Show "Order is locked" message
  showLockedMessage();
}
```

### Get User's Pending Order

```dart
final orderRepo = sl<OrderRepository>();
final pendingOrder = await orderRepo.getUserPendingOrder(userId);

if (pendingOrder != null) {
  // User has a pending order
  print('Pending order: ${pendingOrder.orderNumber}');
} else {
  // No pending order
}
```

### Listen to Order Changes

```dart
final orderRepo = sl<OrderRepository>();
orderRepo.streamOrder(orderId).listen((order) {
  if (order != null) {
    print('Order status: ${order.status.displayName}');
    
    // Update UI based on status
    setState(() {
      _currentOrder = order;
    });
  }
});
```

### Send Custom Notification

```dart
final notificationService = sl<OrderNotificationService>();

// Custom notification
await notificationService._sendToUser(
  userId: userId,
  title: 'Special Offer!',
  body: 'Get 20% off your next order',
  data: {
    'type': 'promotion',
    'discountCode': 'SAVE20',
  },
);
```

---

## Testing Checklist

### User Testing:
- [ ] Create order → Status is pending
- [ ] Add more items → Added to existing order
- [ ] Try to add items after confirmed → Shows locked message OR creates new order
- [ ] Receive notification when status changes
- [ ] Cancel pending order → Works
- [ ] Try to cancel confirmed order → Blocked

### Admin Testing:
- [ ] See new order notification
- [ ] Confirm pending order → Status changes
- [ ] Mark confirmed as arrived → Status changes
- [ ] Try to cancel confirmed → Blocked
- [ ] View status history → Shows all changes
- [ ] Real-time updates → Orders update without refresh

### Edge Cases:
- [ ] User has pending order A, adds items from restaurant B → Creates new order
- [ ] User adds items, admin confirms before checkout → Items go to new order
- [ ] Multiple admins update same order → Last update wins
- [ ] User loses internet during add items → Proper error handling

---

## Performance Tips

### For Large Order Volumes:

1. **Use pagination for order lists:**
```dart
final orders = await orderRepo.getUserOrders(
  userId: userId,
  limit: 20,
  lastOrderId: lastOrderId, // For pagination
);
```

2. **Use streams for real-time updates:**
```dart
// Better than polling
orderRepo.streamUserActiveOrders(userId).listen((orders) {
  // Auto-updates
});
```

3. **Index Firestore fields:**
```
Indexes needed:
- orders: [userId, status, createdAt]
- orders: [restaurantId, status, createdAt]
- notifications: [userId, isRead, createdAt]
```

---

## Support

For issues or questions:
1. Check this guide
2. Check `FIXES_IMPLEMENTATION_SUMMARY.md`
3. Check Firebase console logs
4. Check Firestore data structure

Happy coding! 🎉
