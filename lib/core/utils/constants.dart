class FirestoreCollections {
  static const String users = 'users';
  static const String sessions = 'sessions';
  static const String menuItems = 'menu_items';
  static const String orders = 'orders';

  // Multi-tenant collections
  static const String restaurants = 'restaurants';
  static const String branches = 'branches';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String reviews = 'reviews';
  static const String favorites = 'favorites';
  static const String offers = 'offers';
  static const String carts = 'carts';
  static const String deliveryAddresses = 'delivery_addresses';
  static const String notifications = 'notifications';
}

class AppConstants {
  static const String appName = 'Ftarna';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;

  // Geo constants
  static const double defaultSearchRadiusKm = 10.0;
  static const double maxSearchRadiusKm = 50.0;

  // Pagination
  static const int defaultPageSize = 20;

  // Order constraints
  static const int maxCartItems = 50;
  static const double minOrderAmount = 10.0;
}

/// User roles for role-based access control
enum UserRole {
  user,
  branchAdmin,
  restaurantAdmin,
  superAdmin,
}

/// Order status enum - simplified to 3 states
/// Flow: pending → confirmed → arrived
enum OrderStatus {
  pending,   // User can modify (add/remove/update items)
  confirmed, // Order locked, no modifications allowed
  arrived,
  cancelled
  // Order completed, no modifications allowed
}

/// Extension to get status display name and business logic
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.arrived:
        return 'Arrived';
    }
  }

  /// User can ONLY modify order when status is pending
  bool get canModify => this == OrderStatus.pending;

  /// Alias for backward compatibility
  bool get canAddItems => canModify;

  /// User can only cancel when status is pending
  bool get canCancel => this == OrderStatus.pending;

  /// Get next status in the flow (admin controlled)
  /// pending → confirmed → arrived
  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.arrived;
      case OrderStatus.cancelled:
      case OrderStatus.arrived:
        return null;
    }
  }

  /// Check if order is in final state
  bool get isFinal => this == OrderStatus.arrived;

  /// Check if order is active (not arrived)
  bool get isActive => this != OrderStatus.arrived;
}

/// Discount types for offers
enum DiscountType {
  percentage,
  fixedAmount,
  freeItem,
  buyOneGetOne,
}
