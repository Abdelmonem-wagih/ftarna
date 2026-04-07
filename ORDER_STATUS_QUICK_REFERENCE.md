# 🚀 Order Status Quick Reference

## 3-Status Flow

```
PENDING → CONFIRMED → ARRIVED
```

---

## User Permissions

| Action | Pending | Confirmed | Arrived |
|--------|---------|-----------|---------|
| **Add Items** | ✅ YES | ❌ NO | ❌ NO |
| **Remove Items** | ✅ YES | ❌ NO | ❌ NO |
| **Update Qty** | ✅ YES | ❌ NO | ❌ NO |
| **Cancel Order** | ✅ YES | ❌ NO | ❌ NO |
| **View Order** | ✅ YES | ✅ YES | ✅ YES |

---

## Admin Actions

| Status | Available Actions |
|--------|-------------------|
| **Pending** | Confirm Order, Cancel Order |
| **Confirmed** | Mark as Arrived |
| **Arrived** | (None - Final State) |

---

## Code Snippets

### Check if Order Can Be Modified

```dart
if (order.canModify) {
  // Show edit UI
}
```

### Check if Order Can Be Cancelled

```dart
if (order.canCancel) {
  // Show cancel button
}
```

### Get Next Status

```dart
final next = order.status.nextStatus;
if (next != null) {
  // Show transition button
}
```

### Conditional UI

```dart
// Only show controls when pending
if (order.status == OrderStatus.pending) {
  AddItemButton(),
  RemoveItemButton(),
  CancelOrderButton(),
}

// Show completion message when arrived
if (order.status == OrderStatus.arrived) {
  OrderCompleteMessage(),
}
```

---

## Status Colors

| Status | Color | Hex |
|--------|-------|-----|
| Pending | Orange | #FF9800 |
| Confirmed | Blue | #2196F3 |
| Arrived | Green | #4CAF50 |

---

## Status Icons

| Status | Icon | Material Icon |
|--------|------|---------------|
| Pending | ⏳ | Icons.hourglass_empty |
| Confirmed | ☑️ | Icons.check_circle_outline |
| Arrived | ✅ | Icons.check_circle |

---

## Common Patterns

### In Widgets

```dart
// Show add button conditionally
if (order.canModify)
  ElevatedButton(
    onPressed: addItems,
    child: Text('Add Items'),
  ),
```

### In Repository

```dart
// Validate before modification
if (!order.canModify) {
  throw Exception('Cannot modify');
}
```

### Admin Transitions

```dart
// Safe transition
await orderRepo.updateOrderStatus(
  orderId: order.id,
  newStatus: order.status.nextStatus!,
);
```

---

## Error Messages

| Scenario | Message |
|----------|---------|
| Modify confirmed order | "Order is confirmed and cannot be modified" |
| Cancel confirmed order | "Cannot cancel confirmed orders" |
| Add items to arrived | "Order is complete and cannot be modified" |

---

## Files to Update

When adding new order UI:

1. Check `order.canModify` before showing edit controls
2. Check `order.canCancel` before showing cancel button
3. Use `order.status.nextStatus` for admin actions
4. Use status badge colors from `AppTheme`

---

**Quick Tip:** Always use the status properties (`canModify`, `canCancel`) instead of checking status directly!

✅ Good: `if (order.canModify)`  
❌ Bad: `if (order.status == OrderStatus.pending)`
