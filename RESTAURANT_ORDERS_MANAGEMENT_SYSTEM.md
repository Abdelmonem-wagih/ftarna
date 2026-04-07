# Restaurant Orders Management System - Complete Refactor

## 📋 Overview

This is a complete refactor of the admin orders panel with a clean, focused system for managing grouped restaurant orders with real-time updates and payment tracking.

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/features/admin/
├── domain/
│   └── entities/
│       ├── aggregated_order_item.dart      # Aggregated item entity
│       └── user_orders_summary.dart         # User summary entity
├── presentation/
│   ├── cubit/
│   │   └── restaurant_orders_cubit.dart    # State management
│   ├── pages/
│   │   ├── restaurant_orders_admin_screen.dart       # Main admin screen
│   │   ├── user_order_details_screen.dart            # User details
│   │   └── unpaid_orders_management_screen.dart      # Payment management
│   └── widgets/
│       ├── aggregated_items_section.dart    # Aggregated items widget
│       └── users_list_section.dart          # Users list widget

lib/features/order/
└── presentation/
    └── pages/
        └── user_unpaid_orders_screen.dart   # User-side unpaid view
```

---

## 📊 Data Models

### 1. AggregatedOrderItem
```dart
{
  productId: String,
  nameAr: String,
  nameEn: String,
  imageUrl: String?,
  totalQuantity: int,        // Sum across all orders
  unitPrice: double,
  totalPrice: double         // totalQuantity * unitPrice
}
```

### 2. UserOrdersSummary
```dart
{
  userId: String,
  userName: String,
  userPhone: String?,
  orders: List<OrderEntity>,
  totalAmount: double,       // Total of all orders
  paidAmount: double,        // Total paid
  unpaidAmount: double,      // Total unpaid
  totalOrders: int,
  paidOrders: int,
  unpaidOrders: int
}
```

**Computed Properties:**
- `hasUnpaidOrders`: bool
- `unpaidOrdersList`: List<OrderEntity>
- `paidOrdersList`: List<OrderEntity>
- `paymentCompletionPercentage`: double (0-100)

---

## 🔥 Firestore Structure

### Orders Collection Structure
```
orders/
  {orderId}/
    ├── orderNumber: String
    ├── userId: String
    ├── userName: String
    ├── userPhone: String
    ├── restaurantId: String          # IMPORTANT for filtering
    ├── restaurantNameAr: String
    ├── restaurantNameEn: String
    ├── items: Array<OrderItem>
    ├── status: String (enum)
    ├── total: Number
    ├── isPaid: Boolean               # Payment status
    ├── paidAt: Timestamp?
    ├── isCancelled: Boolean
    ├── createdAt: Timestamp
    └── updatedAt: Timestamp
```

### Indexes Required
```
Collection: orders
- restaurantId (Ascending) + createdAt (Descending)
- restaurantId (Ascending) + isPaid (Ascending)
- userId (Ascending) + isPaid (Ascending)
- userId (Ascending) + createdAt (Descending)
```

---

## 🎯 Core Features

### 1. Admin Side

#### A. Main Screen (`RestaurantOrdersAdminScreen`)

**Top Summary Cards:**
- Total Revenue
- Total Paid
- Total Unpaid (highlighted if > 0)
- Total Users

**Aggregated Items Section:**
- Shows combined items from ALL orders
- Real-time updates when:
  - New order added
  - Order deleted
  - Quantity changed
- Displays:
  - Item image/icon
  - Item name (localized)
  - Total quantity (across all orders)
  - Unit price
  - Total price

**Users List Section:**
- Shows all users who made orders
- Each user shows:
  - Avatar with first letter
  - Name
  - Number of orders
  - Payment status badge
  - Warning badge if has unpaid orders
  - Total amount
  - Unpaid amount (if any)
- Click to view user's order details

#### B. User Details Screen (`UserOrderDetailsScreen`)

Shows when clicking a user from the list:

**Summary Section:**
- Total Amount
- Paid Amount
- Unpaid Amount
- Payment Completion %

**Orders List:**
- All orders for this user
- Each order shows:
  - Order number
  - Date/time
  - Payment status
  - Items list
  - Total price

#### C. Unpaid Orders Management (`UnpaidOrdersManagementScreen`)

Accessed via payment icon in app bar:

**Features:**
- Shows ONLY users with unpaid orders
- Sorted by unpaid amount (highest first)
- Unpaid count badge on icon
- Each user card:
  - Warning badge
  - Expandable to show unpaid orders
  - Each order:
    - Order details
    - Items preview
    - "Mark as Paid" button

**Mark as Paid Flow:**
1. Admin clicks "Mark as Paid"
2. Confirmation dialog
3. Order updated in Firestore
4. Real-time update everywhere:
   - Removed from unpaid list
   - Admin totals update
   - User unpaid list updates

---

### 2. User Side

#### Unpaid Orders Screen (`UserUnpaidOrdersScreen`)

**Features:**
- Shows user's own unpaid orders
- Top card with:
  - Total unpaid amount
  - Number of unpaid orders
  - Attractive gradient design
- List of unpaid orders:
  - Order number
  - Date
  - Items
  - Total
  - Unpaid badge

**Real-time Updates:**
- When admin marks order as paid:
  - Order disappears from list
  - Total updates instantly
  - If no unpaid orders → shows success message

---

## 🔄 State Management (Cubit)

### RestaurantOrdersCubit

**States:**
- `RestaurantOrdersInitial`
- `RestaurantOrdersLoading`
- `RestaurantOrdersLoaded`
  - allOrders
  - aggregatedItems
  - usersSummaries
  - totalRevenue
  - totalPaid
  - totalUnpaid
- `RestaurantOrdersError`

**Methods:**
- `loadRestaurantOrders(restaurantId)` - Start real-time stream
- `markOrderAsPaid(orderId)` - Mark order as paid
- `deleteOrder(orderId)` - Delete order

**Internal Logic:**

1. **Aggregation (_aggregateItems)**
   - Loop through all orders
   - Group items by productId
   - Sum quantities
   - Calculate totals
   - Sort by quantity descending

2. **Grouping (_groupOrdersByUser)**
   - Group orders by userId
   - Create UserOrdersSummary for each user
   - Calculate all metrics
   - Sort by total amount descending

**Real-time Stream:**
```dart
orderRepository.streamRestaurantOrders(restaurantId: restaurantId)
  .listen(_handleOrdersUpdate)
```

Automatically updates when:
- New order created
- Order updated
- Order deleted
- Payment status changed

---

## 🎨 UI/UX Features

### Design System
- Uses existing `AppTheme` colors
- Modern card-based layout
- Clean spacing and borders
- Smooth animations

### Visual Indicators
- ⚠️ Warning badge for unpaid users
- 🔴 Red badge count on payment icon
- Color-coded payment status:
  - Green: Paid
  - Orange: Unpaid
- Border highlighting for unpaid items

### Animations
- Smooth scroll to top FAB
- Expandable order details
- Pull-to-refresh
- Real-time updates (no flickering)

### Responsive
- Works on all screen sizes
- Horizontal scroll for aggregated items on small screens
- Touch-friendly button sizes

---

## ✨ Bonus Features Implemented

### 1. Smart Highlighting
- Users with unpaid orders have warning badge
- Unpaid orders have colored borders
- Amount highlighted in warning color

### 2. Sticky Total
- Summary cards always visible at top
- Shows key metrics at a glance

### 3. Sorting
- Users sorted by total amount
- Unpaid users sorted by unpaid amount
- Items sorted by quantity

### 4. Badge System
- Unpaid count badge on payment icon
- Warning badges on user avatars
- Status badges for payment state

### 5. User Experience
- Confirmation dialogs for actions
- Success messages with snackbars
- Empty states with helpful messages
- Loading states
- Error handling

---

## 🚀 Usage

### Admin Access

1. **View All Orders:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (_) => RestaurantOrdersAdminScreen(),
     ),
   );
   ```

2. **Manage Unpaid Orders:**
   - Click payment icon in app bar
   - Or navigate directly:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (_) => UnpaidOrdersManagementScreen(),
     ),
   );
   ```

### User Access

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => UserUnpaidOrdersScreen(),
  ),
);
```

---

## 🔧 Integration

### Update Home Screen Navigation

Replace old admin screen with new one:

```dart
// In home screen or navigation
final screens = [
  const ModernRestaurantListScreen(),
  const OrdersListScreen(),
  if (isAdmin) const RestaurantOrdersAdminScreen(), // NEW
  const SettingsScreen(),
];
```

### Add Unpaid Orders to User Menu

In user settings or orders screen:

```dart
ListTile(
  leading: Icon(Icons.payment),
  title: Text('Unpaid Orders'),
  trailing: unpaidCount > 0 
    ? Badge(label: Text('$unpaidCount'))
    : null,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserUnpaidOrdersScreen(),
    ),
  ),
)
```

---

## 📈 Performance Optimization

### 1. Real-time Streams
- Single stream per screen
- Automatic updates (no polling)
- Proper cleanup in dispose

### 2. Efficient Aggregation
- O(n) complexity for aggregation
- Map-based grouping
- Single pass through orders

### 3. Widget Optimization
- ListView with separators
- Const constructors where possible
- Minimal rebuilds with BlocBuilder

### 4. Memory Management
- StreamSubscription cleanup
- Proper disposal of controllers
- No memory leaks

---

## 🧪 Testing Scenarios

### Admin Tests
1. ✅ View empty state
2. ✅ View orders with items
3. ✅ See aggregated totals
4. ✅ Click user → view details
5. ✅ Mark order as paid
6. ✅ See real-time updates
7. ✅ Filter unpaid orders

### User Tests
1. ✅ View unpaid orders
2. ✅ See total unpaid amount
3. ✅ Real-time update when paid
4. ✅ Empty state when all paid

### Real-time Tests
1. ✅ New order → aggregation updates
2. ✅ Delete order → list updates
3. ✅ Mark paid → removed from unpaid
4. ✅ Multiple users update simultaneously

---

## 🎯 Key Benefits

### 1. Clean & Focused
- Single purpose screens
- No unnecessary features
- Clear navigation flow

### 2. Real-time Everything
- Instant updates
- No refresh needed
- Always current data

### 3. Easy Payment Management
- Quick unpaid overview
- One-click payment marking
- Visual feedback

### 4. User-friendly
- Intuitive UI
- Clear status indicators
- Helpful messages

### 5. Scalable
- Efficient aggregation
- Clean architecture
- Easy to extend

---

## 🔮 Future Enhancements

1. **Export to Excel**
   - Export aggregated items
   - Export user summaries

2. **Filters**
   - Date range
   - Payment status
   - Amount range

3. **Statistics**
   - Charts for trends
   - Popular items
   - Revenue over time

4. **Notifications**
   - Remind users about unpaid orders
   - Alert admin for long unpaid periods

5. **Bulk Actions**
   - Mark multiple orders as paid
   - Export selected orders

6. **Search**
   - Search users
   - Search items
   - Search order numbers

---

## 📝 Migration Guide

### From Old Admin Panel

1. **Replace imports:**
   ```dart
   // Old
   import 'admin_orders_panel_screen.dart';
   
   // New
   import 'restaurant_orders_admin_screen.dart';
   ```

2. **Update navigation:**
   ```dart
   // Old
   AdminOrdersPanelScreen()
   
   // New
   RestaurantOrdersAdminScreen()
   ```

3. **No data migration needed** - Uses existing orders collection

4. **Optional:** Add unpaid orders link to user menu

---

## 🤝 Dependencies

All dependencies already exist in the project:
- flutter_bloc
- cloud_firestore
- intl
- equatable

No new packages required!

---

## 📞 Support

For issues or questions about this implementation:
- Check state management in cubit
- Verify Firestore indexes
- Check user restaurantId assignment
- Ensure orders have correct restaurantId

---

**Built with ❤️ using Clean Architecture & BLoC Pattern**
