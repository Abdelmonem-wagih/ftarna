import '../entities/product_entity.dart';

/// Product repository interface
abstract class ProductRepository {
  /// Get all products for a restaurant
  Future<List<ProductEntity>> getProductsByRestaurant(String restaurantId);

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);

  /// Get product by ID
  Future<ProductEntity?> getProductById(String id);

  /// Search products
  Future<List<ProductEntity>> searchProducts({
    required String query,
    String? restaurantId,
    String? categoryId,
  });

  /// Get featured products
  Future<List<ProductEntity>> getFeaturedProducts({
    String? restaurantId,
    int? limit,
  });

  /// Get popular products
  Future<List<ProductEntity>> getPopularProducts({
    String? restaurantId,
    int? limit,
  });

  /// Create a new product
  Future<ProductEntity> createProduct(ProductEntity product);

  /// Update product
  Future<void> updateProduct(ProductEntity product);

  /// Delete product
  Future<void> deleteProduct(String id);

  /// Toggle product availability
  Future<void> toggleAvailability(String productId, bool isAvailable);

  /// Toggle branch-specific availability
  Future<void> toggleBranchAvailability(
    String productId,
    String branchId,
    bool isAvailable,
  );

  /// Stream products for a restaurant (real-time)
  Stream<List<ProductEntity>> streamProducts(String restaurantId);

  /// Stream products by category
  Stream<List<ProductEntity>> streamProductsByCategory(String categoryId);

  /// Stream single product
  Stream<ProductEntity?> streamProduct(String id);

  /// Increment order count
  Future<void> incrementOrderCount(String productId);

  /// Update product rating
  Future<void> updateRating(String productId, double newRating, int totalReviews);

  /// Batch create products (for OCR import)
  Future<List<ProductEntity>> batchCreateProducts(List<ProductEntity> products);
}
