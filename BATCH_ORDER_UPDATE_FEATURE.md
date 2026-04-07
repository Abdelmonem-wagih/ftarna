# Batch Order Status Update Feature

## Overview
This feature allows restaurant admins to update the status of ALL active orders at once with a single button click.

---

## 📋 Implementation Summary

### 1. **Repository Layer**

#### Added to `OrderRepository` interface:
```dart
/// Batch update order status for multiple orders
Future<void> batchUpdateOrderStatus({
  required List<String> orderIds,
  required OrderStatus newStatus,
  String? note,
  String? updatedBy,
});
```

#### Implemented in `OrderRepositoryImpl`:
- Uses Firestore **batch write** for atomic updates
- Updates status and statusHistory for all orders
- Automatically sends notifications to all affected users
- Transaction-safe: either all orders update or none

**Key Features:**
- ✅ Batch processing for better performance
- ✅ Atomic updates (all or nothing)
- ✅ Automatic notification sending
- ✅ Status history tracking

---

### 2. **Cubit Layer** (`RestaurantOrdersCubit`)

#### New State Properties in `RestaurantOrdersLoaded`:

```dart
/// Get the global status (most common status among active orders)
OrderStatus? get globalStatus

/// Get next status for batch update
OrderStatus? get nextGlobalStatus

/// Check if all active orders have the same status
bool get hasUniformStatus
```

**Logic:**
- `globalStatus`: Finds the most common status among active orders (not cancelled, not arrived)
- `nextGlobalStatus`: Returns the next status in the flow (pending → confirmed → arrived)
- `hasUniformStatus`: Checks if all active orders have the same status

#### New Method:

```dart
Future<void> updateAllOrdersToNextStatus({String? updatedBy})
```

**Workflow:**
1. Get current state
2. Calculate next global status
3. Filter active orders that can be updated
4. Call repository batch update
5. Stream automatically refreshes with new data

---

### 3. **UI Layer** (`RestaurantOrdersAdminScreen`)

#### Button in AppBar:
- **Icon:** Update icon with a colored indicator
- **Visibility:** Only shown when there are orders that can be updated
- **Tooltip:** Dynamic text based on next status
  - "Confirm All Orders" (pending → confirmed)
  - "Mark All as Arrived" (confirmed → arrived)

#### Confirmation Dialog:
**Shows:**
- Number of orders to be updated
- Current status → Next status (with color badges)
- Warning about user notifications

**Actions:**
- Cancel button
- Confirm button (calls `updateAllOrdersToNextStatus()`)

**Safety Features:**
- ✅ Confirmation dialog prevents accidental clicks
- ✅ Shows exact number of orders affected
- ✅ Visual status transition preview
- ✅ Warning about notifications

---

## 🎯 Status Flow

```
pending → confirmed → arrived
   ↓
cancelled (only from pending)
```

### Button Behavior:

| Current Global Status | Button Text | Next Status | Button Visible? |
|----------------------|-------------|-------------|-----------------|
| Pending | "Confirm All Orders" | Confirmed | ✅ Yes |
| Confirmed | "Mark All as Arrived" | Arrived | ✅ Yes |
| Arrived | N/A | N/A | ❌ No |
| No active orders | N/A | N/A | ❌ No |

---

## 🔔 Notifications

After batch update, **all users** with affected orders receive a notification:

### For `confirmed` status:
```
Title: ✅ Order Confirmed #ORD-123456
Body: Your order has been confirmed and is being prepared
```

### For `arrived` status:
```
Title: 🎉 Order Arrived #ORD-123456
Body: Your order has arrived! Enjoy your meal!
```

**Implementation:**
- Asynchronous (doesn't block the UI)
- Fire-and-forget (errors logged but don't fail the update)
- Individual notifications per order (personalized)

---

## 💻 Usage Examples

### Admin clicks the update button:

1. **Initial state:** 5 pending orders

2. **Admin clicks update icon**
   - Confirmation dialog shows: "5 orders will be updated"
   - Status badge: "Pending → Confirmed"

3. **Admin confirms**
   - All 5 orders updated to "confirmed"
   - All 5 users receive notifications
   - UI updates in real-time
   - Success message: "✅ All orders updated to Confirmed"

4. **Admin clicks again**
   - Confirmation dialog shows: "5 orders will be updated"
   - Status badge: "Confirmed → Arrived"

5. **Admin confirms**
   - All 5 orders updated to "arrived"
   - All 5 users receive notifications
   - Button disappears (no more updates needed)
   - Success message: "✅ All orders updated to Arrived"

---

## 🧪 Testing Checklist

### Basic Functionality:
- [ ] Button appears when there are active orders
- [ ] Button shows correct tooltip
- [ ] Confirmation dialog displays correctly
- [ ] Dialog shows correct number of orders
- [ ] Dialog shows correct status transition

### Status Updates:
- [ ] Pending → Confirmed works
- [ ] Confirmed → Arrived works
- [ ] Button disappears when all arrived
- [ ] Cancelled orders are excluded
- [ ] Arrived orders are excluded

### Real-time Updates:
- [ ] Orders update in real-time after batch update
- [ ] UI refreshes automatically
- [ ] Other admin screens update too

### Notifications:
- [ ] Users receive notifications
- [ ] Notification content is correct
- [ ] Multiple notifications sent correctly

### Error Handling:
- [ ] Error message shown on failure
- [ ] State restored after error
- [ ] Retry works after error

### Edge Cases:
- [ ] No active orders → button hidden
- [ ] All orders arrived → button hidden
- [ ] Mixed status orders → uses most common status
- [ ] Single order → works correctly

---

## 🔐 Security & Permissions

**Who can use this feature?**
- ✅ Restaurant admins
- ✅ Super admins
- ❌ Regular users
- ❌ Branch admins (unless they manage the restaurant)

**Validation:**
- User must have `restaurantId` assigned
- User must be authenticated
- Orders must belong to the admin's restaurant

---

## 🎨 UI Components

### Update Button:
```dart
IconButton(
  icon: Stack(
    children: [
      Icon(Icons.update),
      Positioned(/* Color indicator */),
    ],
  ),
  tooltip: _getStatusUpdateTooltip(nextStatus),
  onPressed: () => _showBatchUpdateConfirmation(...),
)
```

### Confirmation Dialog:
- **Title:** "Update All Orders" with icon
- **Content:** 
  - Confirmation message
  - Order count
  - Status transition badges
  - Warning message
- **Actions:** Cancel & Confirm buttons

---

## 📊 Performance Considerations

### Batch Write Benefits:
- ✅ Single network call instead of N calls
- ✅ Atomic operation (all or nothing)
- ✅ Better Firestore quota usage
- ✅ Faster execution

### Notification Strategy:
- Async/fire-and-forget
- Doesn't block UI updates
- Individual notifications for personalization

### Real-time Updates:
- Stream-based (no manual refresh needed)
- Automatic UI updates
- No state management complexity

---

## 🐛 Troubleshooting

### Issue: Button not appearing
**Check:**
- Are there any active orders?
- Are all orders already "arrived"?
- Are all orders cancelled?

### Issue: Updates not working
**Check:**
- Network connection
- Firestore permissions
- User authentication
- Restaurant ID assignment

### Issue: Notifications not received
**Check:**
- FCM token registration
- Notification permissions
- OrderNotificationService configuration
- User device settings

---

## 🚀 Future Enhancements

Possible improvements:
1. **Selective batch update:** Select specific orders to update
2. **Schedule updates:** Auto-update at specific times
3. **Undo feature:** Revert last batch update
4. **Audit log:** Track who performed batch updates
5. **Custom statuses:** Allow custom workflow beyond 3 states
6. **Bulk actions:** Cancel all, mark all paid, etc.

---

## 📝 Code Files Modified

1. `lib/features/order/domain/repositories/order_repository.dart`
   - Added `batchUpdateOrderStatus()` method signature

2. `lib/features/order/data/repositories/order_repository_impl.dart`
   - Implemented `batchUpdateOrderStatus()` with Firestore batch write

3. `lib/features/admin/presentation/cubit/restaurant_orders_cubit.dart`
   - Added `globalStatus`, `nextGlobalStatus`, `hasUniformStatus` getters
   - Added `updateAllOrdersToNextStatus()` method

4. `lib/features/admin/presentation/pages/restaurant_orders_admin_screen.dart`
   - Added batch update button in AppBar
   - Added confirmation dialog
   - Added helper methods for status display

---

## ✅ Summary

This feature provides a powerful and safe way for restaurant admins to manage order statuses efficiently:

- **Single click** updates all orders
- **Atomic transactions** ensure data consistency
- **Real-time updates** keep UI in sync
- **User notifications** keep customers informed
- **Safety measures** prevent accidental updates
- **Performance optimized** with batch operations

The implementation follows Flutter best practices with clean separation of concerns across repository, cubit, and UI layers.
