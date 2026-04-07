import '../entities/cart_entity.dart';
import '../../../restaurant/domain/entities/restaurant_entity.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../order/domain/entities/order_entity.dart';

/// Cart repository interface
abstract class CartRepository {
  /// Get user's cart
  Future<CartEntity?> getCart(String userId);

  /// Create or update cart
  Future<CartEntity> saveCart(CartEntity cart);

  /// Add item to cart
  Future<CartEntity> addToCart({
    required String userId,
    required ProductEntity product,
    required int quantity,
    required RestaurantEntity restaurant,
    // required BranchEntity branch,
    List<SelectedVariation>? selectedVariations,
    String? specialInstructions,
  });

  /// Update item quantity
  Future<CartEntity> updateItemQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  });

  /// Remove item from cart
  Future<CartEntity> removeFromCart({
    required String userId,
    required String itemId,
  });

  /// Clear cart
  Future<void> clearCart(String userId);

  /// Apply discount code
  Future<CartEntity> applyDiscountCode({
    required String userId,
    required String code,
  });

  /// Remove discount
  Future<CartEntity> removeDiscount(String userId);

  /// Stream cart (real-time updates)
  Stream<CartEntity?> streamCart(String userId);

  /// Get local cart (from shared preferences)
  Future<CartEntity?> getLocalCart();

  /// Save local cart
  Future<void> saveLocalCart(CartEntity cart);

  /// Clear local cart
  Future<void> clearLocalCart();

  /// Sync local cart to server
  Future<CartEntity?> syncLocalCartToServer(String userId);
}
