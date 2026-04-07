# 🎨 System Flow Diagrams

## 1. Complete Order Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER CREATES ORDER                           │
│  User → Restaurant → Cart → Checkout → Order (pending)         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  Notifications  │
                    │  Admin: 🔔 New  │
                    │  Order Created  │
                    └─────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                 PENDING STATE (EDITABLE)                        │
│  ✅ User can add/remove items                                   │
│  ✅ User can cancel order                                        │
│  ✅ Admin can confirm or cancel                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    Admin clicks "Confirm"
                              ↓
                    ┌─────────────────┐
                    │  Notifications  │
                    │  User: ✅ Order │
                    │    Confirmed    │
                    └─────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                CONFIRMED STATE (LOCKED)                         │
│  ❌ User cannot modify                                           │
│  ❌ User cannot cancel                                           │
│  ✅ Admin can mark as arrived                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    Admin clicks "Mark as Arrived"
                              ↓
                    ┌─────────────────┐
                    │  Notifications  │
                    │  User: 🎉 Order│
                    │     Arrived     │
                    └─────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  ARRIVED STATE (FINAL)                          │
│  ✅ Order complete                                               │
│  ❌ No modifications allowed                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Add Items to Pending Order Flow

```
┌──────────────────────────────────────────────────────────────────┐
│  SCENARIO: User has pending order and wants to add more items  │
└──────────────────────────────────────────────────────────────────┘

Step 1: User opens order details
┌─────────────────────┐
│   Order Details     │
│  Status: Pending    │
│  [Add More Items]   │ ← User clicks
└─────────────────────┘
           ↓
Step 2: Set pending order context
┌─────────────────────┐
│ PendingOrderCubit   │
│ .setPendingOrder()  │
└─────────────────────┘
           ↓
Step 3: Navigate to home
┌─────────────────────┐
│  Restaurants List   │
│  (Home Screen)      │
└─────────────────────┘
           ↓
Step 4: User adds items
┌─────────────────────┐
│   Shopping Cart     │
│  New items added    │
└─────────────────────┘
           ↓
Step 5: Checkout
┌─────────────────────────────────────────┐
│          Checkout Screen                │
│                                         │
│  Check: Is there pending order?        │
│         ↓                     ↓         │
│       YES                    NO         │
│         ↓                     ↓         │
│  Same restaurant?      Create new      │
│   ↓           ↓            order       │
│  YES          NO                        │
│   ↓           ↓                         │
│  Add to    Create new                  │
│ existing    order                      │
└─────────────────────────────────────────┘
           ↓
Step 6: Result
┌────────────────────────────────────────┐
│  IF Pending + Same Restaurant:         │
│    → Items added to existing order     │
│    → Order total updated               │
│    → Same order ID                     │
│                                        │
│  ELSE:                                 │
│    → New order created                 │
│    → New order ID                      │
└────────────────────────────────────────┘
```

---

## 3. Notification System Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION TRIGGERS                       │
└────────────────────────────────────────────────────────────────┘

Trigger 1: New Order Created
User creates order → OrderRepository.createOrder()
                            ↓
              OrderNotificationService.notifyNewOrder()
                            ↓
                    ┌───────────────┐
                    │  Save to DB   │
                    │  Firestore:   │
                    │ notifications/│
                    └───────────────┘
                            ↓
                    ┌───────────────┐
                    │  Send to:     │
                    │  All Admins   │
                    │  (FCM ready)  │
                    └───────────────┘

Trigger 2: Status Changed
Admin updates status → OrderRepository.updateOrderStatus()
                              ↓
          OrderNotificationService.notifyOrderStatusChange()
                              ↓
                      ┌───────────────┐
                      │  Save to DB   │
                      │  Firestore:   │
                      │ notifications/│
                      └───────────────┘
                              ↓
                      ┌───────────────┐
                      │  Send to:     │
                      │  Order User   │
                      │  (FCM ready)  │
                      └───────────────┘

Trigger 3: Payment Done
Mark as paid → OrderRepository.markAsPaid()
                      ↓
      OrderNotificationService.notifyPaymentDone()
                      ↓
              ┌───────────────┐
              │  Save to DB   │
              │  Firestore:   │
              │ notifications/│
              └───────────────┘
                      ↓
              ┌───────────────┐
              │  Send to:     │
              │ User + Admin  │
              │  (FCM ready)  │
              └───────────────┘
```

---

## 4. Admin Dashboard Flow

```
┌────────────────────────────────────────────────────────────────┐
│                     ADMIN PANEL VIEW                           │
└────────────────────────────────────────────────────────────────┘

┌──────────────┬──────────────┬──────────────┐
│   PENDING    │  CONFIRMED   │   ARRIVED    │
│              │              │              │
│  Order #123  │  Order #456  │  Order #789  │
│  User: Ali   │  User: Sara  │  User: Omar  │
│  5 items     │  3 items     │  2 items     │
│  150 EGP     │  80 EGP      │  45 EGP      │
│              │              │              │
│ [Confirm]    │[Mark Arrived]│   (Final)    │
│ [Cancel]     │              │              │
└──────────────┴──────────────┴──────────────┘
       ↓               ↓               
   Admin Action   Admin Action       
       ↓               ↓               
┌──────────────┐ ┌──────────────┐    
│ Update DB    │ │ Update DB    │    
│ Add history  │ │ Add history  │    
│ Send notif   │ │ Send notif   │    
└──────────────┘ └──────────────┘    
       ↓               ↓               
   User notified   User notified      
```

---

## 5. Status History Tracking

```
┌────────────────────────────────────────────────────────────────┐
│                  STATUS HISTORY STRUCTURE                      │
└────────────────────────────────────────────────────────────────┘

Order Document in Firestore:
{
  id: "order123",
  orderNumber: "ORD-20260407-ABC123",
  status: "confirmed",  ← Current status
  statusHistory: [      ← Complete history
    {
      status: "pending",
      timestamp: "2026-04-07T10:00:00Z",
      note: "Order placed",
      updatedBy: null
    },
    {
      status: "confirmed",
      timestamp: "2026-04-07T10:15:00Z",
      note: "Confirmed by admin",
      updatedBy: "admin_user_id"
    }
  ],
  ...other fields
}

Visual Timeline for User:
┌────────────────────────────────────────┐
│   Order Status Timeline                │
│                                        │
│  ✅ Pending                            │
│     10:00 AM - Order placed            │
│                                        │
│  ✅ Confirmed                          │
│     10:15 AM - Confirmed by admin      │
│                                        │
│  ⏳ Arrived                            │
│     Waiting...                         │
└────────────────────────────────────────┘
```

---

## 6. Decision Tree: Add Items Logic

```
                 User clicks "Add More Items"
                          ↓
                  Is order pending?
                   ↙         ↘
                 YES          NO
                  ↓            ↓
          Navigate to    [Button Hidden]
          restaurants      Order locked
                  ↓
          User adds items
                  ↓
          Goes to checkout
                  ↓
          Check pending order
                  ↓
        ┌─────────────────────┐
        │ Query Firestore:    │
        │ getUserPendingOrder │
        └─────────────────────┘
                  ↓
         Pending order exists?
           ↙           ↘
         YES            NO
          ↓              ↓
    Same restaurant?   Create new
      ↙        ↘        order
    YES        NO
     ↓          ↓
  Add to     Create new
  existing    order
  order
```

---

## 7. Firestore Collections Structure

```
Firestore Database
├── users/
│   └── {userId}
│       ├── name
│       ├── email
│       ├── role (user/admin)
│       ├── fcmTokens: []
│       └── ...
│
├── orders/
│   └── {orderId}
│       ├── orderNumber
│       ├── userId
│       ├── status (pending/confirmed/arrived/cancelled)
│       ├── statusHistory: [
│       │   { status, timestamp, note, updatedBy }
│       │ ]
│       ├── items: []
│       ├── total
│       ├── restaurantId
│       ├── createdAt
│       └── ...
│
└── notifications/
    └── {notificationId}
        ├── userId (recipient)
        ├── title
        ├── body
        ├── data: { type, orderId, ... }
        ├── isRead: false
        ├── createdAt
        └── ...
```

---

## 8. Complete System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      FTARNA ORDER SYSTEM                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│     USER     │         │    ADMIN     │         │   FIREBASE   │
│    (App)     │         │   (Panel)    │         │  (Backend)   │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │                        │                        │
       │ Create Order           │                        │
       ├───────────────────────────────────────────────→│
       │                        │                        │
       │                        │← New Order Notification│
       │                        │◄──────────────────────┤
       │                        │                        │
       │                        │ Confirm Order          │
       │                        ├───────────────────────→│
       │                        │                        │
       │← Confirmed Notification│                        │
       │◄──────────────────────────────────────────────┤
       │                        │                        │
       │ Add Items (pending)    │                        │
       ├───────────────────────────────────────────────→│
       │← Items Added           │                        │
       │◄──────────────────────────────────────────────┤
       │                        │                        │
       │                        │ Mark Arrived           │
       │                        ├───────────────────────→│
       │                        │                        │
       │← Arrived Notification  │                        │
       │◄──────────────────────────────────────────────┤
       │                        │                        │

Features:
✅ Real-time order updates (Firestore streams)
✅ Status management (3-state flow)
✅ Notification system (FCM-ready)
✅ Pending order editing
✅ Status history tracking
✅ Business rule validation
```

---

## Legend

```
Symbols Used:
─────  Flow direction
  ↓    Downward flow
  →    Action/Request
  ←    Response/Notification
  ✅    Allowed/Success
  ❌    Not allowed/Blocked
  ⏳    In progress/Waiting
  🔔    Notification
```

---

## Quick Reference

### Status Colors:
- 🟠 **Pending**: Orange (editable)
- 🔵 **Confirmed**: Blue (locked, in progress)
- 🟢 **Arrived**: Green (completed)
- 🔴 **Cancelled**: Red (terminated)

### User Actions by Status:
- **Pending**: Add/remove items, cancel
- **Confirmed**: View only
- **Arrived**: View only, rate (future)
- **Cancelled**: View only

### Admin Actions by Status:
- **Pending**: Confirm, cancel
- **Confirmed**: Mark as arrived
- **Arrived**: None (final)
- **Cancelled**: None (final)

---

*For implementation details, see FIXES_IMPLEMENTATION_SUMMARY.md*
*For usage guide, see QUICK_START_GUIDE.md*
