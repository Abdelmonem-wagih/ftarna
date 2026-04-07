# Order Status Visual Flow Diagram

```
╔═══════════════════════════════════════════════════════════════════════╗
║                    ORDER STATUS LIFECYCLE                              ║
╚═══════════════════════════════════════════════════════════════════════╝

                          ┌─────────────────┐
                          │  USER PLACES    │
                          │     ORDER       │
                          └────────┬────────┘
                                   │
                                   ▼
        ╔══════════════════════════════════════════════════════╗
        ║              STATUS: PENDING (🟠)                    ║
        ╠══════════════════════════════════════════════════════╣
        ║                                                      ║
        ║  USER CAN:                    ADMIN CAN:            ║
        ║  ✅ Add items                 ✅ Confirm order      ║
        ║  ✅ Remove items              ✅ Cancel order       ║
        ║  ✅ Update quantities                              ║
        ║  ✅ Cancel order                                   ║
        ║                                                      ║
        ║  UI SHOWS:                                          ║
        ║  • Add Item button                                  ║
        ║  • Remove buttons                                   ║
        ║  • Quantity +/- controls                            ║
        ║  • Cancel Order button                              ║
        ╚══════════════════════════════════════════════════════╝
                                   │
                                   │ Admin clicks
                                   │ "Confirm Order"
                                   ▼
        ╔══════════════════════════════════════════════════════╗
        ║            STATUS: CONFIRMED (🔵)                    ║
        ╠══════════════════════════════════════════════════════╣
        ║                                                      ║
        ║  USER CAN:                    ADMIN CAN:            ║
        ║  ❌ Add items                 ✅ Mark as arrived    ║
        ║  ❌ Remove items              ❌ Cancel             ║
        ║  ❌ Update quantities                              ║
        ║  ❌ Cancel order                                   ║
        ║                                                      ║
        ║  UI SHOWS:                                          ║
        ║  • View-only mode                                   ║
        ║  • "Order in progress" message                      ║
        ║  • No edit controls                                 ║
        ║  • Order tracking timeline                          ║
        ╚══════════════════════════════════════════════════════╝
                                   │
                                   │ Admin clicks
                                   │ "Mark as Arrived"
                                   ▼
        ╔══════════════════════════════════════════════════════╗
        ║             STATUS: ARRIVED (🟢)                     ║
        ╠══════════════════════════════════════════════════════╣
        ║                                                      ║
        ║  USER CAN:                    ADMIN CAN:            ║
        ║  ❌ Add items                 ❌ Nothing            ║
        ║  ❌ Remove items              (Final state)         ║
        ║  ❌ Update quantities                              ║
        ║  ❌ Cancel order                                   ║
        ║                                                      ║
        ║  UI SHOWS:                                          ║
        ║  • "Order Complete" ✅                              ║
        ║  • Order Again button                               ║
        ║  • Receipt/Summary                                  ║
        ║  • No edit controls                                 ║
        ╚══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════

                        CANCEL FLOW (Optional)

        ╔══════════════════════════════════════════════════════╗
        ║              STATUS: PENDING (🟠)                    ║
        ╚══════════════════════════════════════════════════════╝
                                   │
                                   │ User/Admin clicks
                                   │ "Cancel Order"
                                   ▼
        ╔══════════════════════════════════════════════════════╗
        ║            STATUS: CANCELLED (🔴)                    ║
        ╠══════════════════════════════════════════════════════╣
        ║                                                      ║
        ║  • Order terminated                                  ║
        ║  • No further actions possible                       ║
        ║  • Refund may be initiated                          ║
        ║  • Shows cancellation reason                         ║
        ║                                                      ║
        ╚══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════

                    PERMISSION MATRIX

┌─────────────────┬──────────┬───────────┬──────────┬───────────┐
│     ACTION      │ PENDING  │ CONFIRMED │ ARRIVED  │ CANCELLED │
├─────────────────┼──────────┼───────────┼──────────┼───────────┤
│ Add Items       │    ✅    │     ❌    │    ❌    │     ❌    │
│ Remove Items    │    ✅    │     ❌    │    ❌    │     ❌    │
│ Update Quantity │    ✅    │     ❌    │    ❌    │     ❌    │
│ Cancel (User)   │    ✅    │     ❌    │    ❌    │     ❌    │
│ Confirm (Admin) │    ✅    │     -     │    -     │     -     │
│ Mark Arrived    │    ❌    │     ✅    │    -     │     ❌    │
│ Cancel (Admin)  │    ✅    │     ❌    │    ❌    │     -     │
│ View Details    │    ✅    │     ✅    │    ✅    │     ✅    │
└─────────────────┴──────────┴───────────┴──────────┴───────────┘

═══════════════════════════════════════════════════════════════════════

                    CODE IMPLEMENTATION

┌───────────────────────────────────────────────────────────────────┐
│  CHECK IF ORDER CAN BE MODIFIED                                   │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  // ✅ CORRECT WAY                                                │
│  if (order.canModify) {                                           │
│    showAddItemButton();                                           │
│    showRemoveButton();                                            │
│    showQuantityControls();                                        │
│  } else {                                                         │
│    showViewOnlyMode();                                            │
│  }                                                                │
│                                                                   │
│  // ❌ WRONG WAY (Don't do this)                                  │
│  if (order.status == OrderStatus.pending) { }                    │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│  ADMIN STATUS TRANSITION                                          │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  // Get next status safely                                        │
│  final nextStatus = order.status.nextStatus;                     │
│                                                                   │
│  if (nextStatus != null) {                                        │
│    // Show button to transition                                   │
│    ElevatedButton(                                                │
│      onPressed: () => updateStatus(order.id, nextStatus),        │
│      child: Text('Move to ${nextStatus.displayName}'),           │
│    );                                                             │
│  }                                                                │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════

                    UI COMPONENT VISIBILITY

┌─────────────────────────────────────────────────────────────────┐
│                    PENDING ORDER                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Order #12345                              🟠 Pending     │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                           │ │
│  │  • Item 1                    [➖] 2 [➕]     $10         │ │
│  │  • Item 2                    [➖] 1 [➕]      $5         │ │
│  │                                                           │ │
│  │  [ + Add More Items ]                                    │ │
│  │                                                           │ │
│  │  Total: $15                                               │ │
│  │                                                           │ │
│  │  [ Cancel Order ]                                         │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   CONFIRMED ORDER                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Order #12345                            🔵 Confirmed    │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                           │ │
│  │  ℹ️  Order is being prepared                              │ │
│  │     Changes are no longer allowed                         │ │
│  │                                                           │ │
│  │  • Item 1          x2                        $10         │ │
│  │  • Item 2          x1                         $5         │ │
│  │                                                           │ │
│  │  Total: $15                                               │ │
│  │                                                           │ │
│  │  [ Track Order ]                                          │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    ARRIVED ORDER                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  Order #12345                              🟢 Arrived    │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                           │ │
│  │  ✅ Order Complete!                                       │ │
│  │                                                           │ │
│  │  • Item 1          x2                        $10         │ │
│  │  • Item 2          x1                         $5         │ │
│  │                                                           │ │
│  │  Total: $15                                               │ │
│  │                                                           │ │
│  │  [ Order Again ]      [ View Receipt ]                   │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════

                    VALIDATION FLOW

┌─────────────────────────────────────────────────────────────────┐
│  User tries to add item                                         │
│         │                                                        │
│         ▼                                                        │
│  Check: order.canModify                                         │
│         │                                                        │
│    ┌────┴────┐                                                  │
│    │         │                                                  │
│   ✅        ❌                                                  │
│    │         │                                                  │
│    ▼         ▼                                                  │
│  Allow    Show error:                                           │
│  action   "Cannot modify                                        │
│           confirmed orders"                                     │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════

Legend:
  🟠 Orange = Pending (Waiting)
  🔵 Blue = Confirmed (In Progress)
  🟢 Green = Arrived (Complete)
  🔴 Red = Cancelled (Terminated)
  
  ✅ = Allowed
  ❌ = Not Allowed
  - = Not Applicable
```
