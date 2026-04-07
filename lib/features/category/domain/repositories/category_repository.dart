import '../entities/category_entity.dart';

/// Category repository interface
abstract class CategoryRepository {
  /// Get all categories for a restaurant
  Future<List<CategoryEntity>> getCategoriesByRestaurant(String restaurantId);

  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(String id);

  /// Create a new category
  Future<CategoryEntity> createCategory(CategoryEntity category);

  /// Update category
  Future<void> updateCategory(CategoryEntity category);

  /// Delete category
  Future<void> deleteCategory(String id);

  /// Reorder categories
  Future<void> reorderCategories(List<String> categoryIds);

  /// Stream categories for a restaurant
  Stream<List<CategoryEntity>> streamCategories(String restaurantId);

  /// Batch create categories (for OCR import)
  Future<List<CategoryEntity>> batchCreateCategories(List<CategoryEntity> categories);
}
