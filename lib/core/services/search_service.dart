import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';
import '../../features/restaurant/domain/entities/restaurant_entity.dart';
import '../../features/restaurant/data/models/restaurant_model.dart';
import '../../features/category/domain/entities/category_entity.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/product/domain/entities/product_entity.dart';
import '../../features/product/data/models/product_model.dart';

/// Search result types
enum SearchResultType {
  restaurant,
  category,
  product,
}

/// Search result item
class SearchResult {
  final SearchResultType type;
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final String? subtitle;
  final double? rating;
  final double? price;
  final String? restaurantId;
  final String? categoryId;

  const SearchResult({
    required this.type,
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.subtitle,
    this.rating,
    this.price,
    this.restaurantId,
    this.categoryId,
  });

  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  factory SearchResult.fromRestaurant(RestaurantEntity restaurant) {
    return SearchResult(
      type: SearchResultType.restaurant,
      id: restaurant.id,
      nameAr: restaurant.nameAr,
      nameEn: restaurant.nameEn,
      imageUrl: restaurant.logoUrl,
      subtitle: restaurant.cuisineTypes.join(', '),
      rating: restaurant.rating,
    );
  }

  factory SearchResult.fromCategory(CategoryEntity category) {
    return SearchResult(
      type: SearchResultType.category,
      id: category.id,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      imageUrl: category.imageUrl,
      restaurantId: category.restaurantId,
    );
  }

  factory SearchResult.fromProduct(ProductEntity product) {
    return SearchResult(
      type: SearchResultType.product,
      id: product.id,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      imageUrl: product.imageUrl,
      price: product.effectivePrice,
      rating: product.rating,
      restaurantId: product.restaurantId,
      categoryId: product.categoryId,
    );
  }
}

/// Global search service
class SearchService {
  final FirebaseFirestore _firestore;

  SearchService({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Search across restaurants, categories, and products
  Future<List<SearchResult>> globalSearch(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final results = <SearchResult>[];

    // Search in parallel
    final futures = await Future.wait([
      _searchRestaurants(lowerQuery, query, limit: 5),
      _searchCategories(lowerQuery, query, limit: 5),
      _searchProducts(lowerQuery, query, limit: 10),
    ]);

    results.addAll(futures[0]);
    results.addAll(futures[1]);
    results.addAll(futures[2]);

    return results;
  }

  /// Search restaurants only
  Future<List<SearchResult>> searchRestaurants(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    return _searchRestaurants(query.toLowerCase(), query, limit: limit);
  }

  /// Search categories only
  Future<List<SearchResult>> searchCategories(
    String query, {
    String? restaurantId,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    return _searchCategories(
      query.toLowerCase(),
      query,
      restaurantId: restaurantId,
      limit: limit,
    );
  }

  /// Search products only
  Future<List<SearchResult>> searchProducts(
    String query, {
    String? restaurantId,
    String? categoryId,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    return _searchProducts(
      query.toLowerCase(),
      query,
      restaurantId: restaurantId,
      categoryId: categoryId,
      limit: limit,
    );
  }

  Future<List<SearchResult>> _searchRestaurants(
    String lowerQuery,
    String originalQuery, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.restaurants)
          .where('isActive', isEqualTo: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .where((r) =>
              r.nameEn.toLowerCase().contains(lowerQuery) ||
              r.nameAr.contains(originalQuery) ||
              r.cuisineTypes.any((c) => c.toLowerCase().contains(lowerQuery)))
          .take(limit)
          .map((r) => SearchResult.fromRestaurant(r))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchCategories(
    String lowerQuery,
    String originalQuery, {
    String? restaurantId,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestoreCollections.categories)
          .where('isActive', isEqualTo: true);

      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      }

      final snapshot = await query.limit(100).get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .where((c) =>
              c.nameEn.toLowerCase().contains(lowerQuery) ||
              c.nameAr.contains(originalQuery))
          .take(limit)
          .map((c) => SearchResult.fromCategory(c))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchProducts(
    String lowerQuery,
    String originalQuery, {
    String? restaurantId,
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestoreCollections.products)
          .where('isActive', isEqualTo: true);

      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      }

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final snapshot = await query.limit(100).get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((p) =>
              p.nameEn.toLowerCase().contains(lowerQuery) ||
              p.nameAr.contains(originalQuery) ||
              (p.descriptionEn?.toLowerCase().contains(lowerQuery) ?? false) ||
              (p.descriptionAr?.contains(originalQuery) ?? false) ||
              p.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
          .take(limit)
          .map((p) => SearchResult.fromProduct(p))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get search suggestions based on popular items
  Future<List<String>> getSearchSuggestions(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final suggestions = <String>{};

    // Get popular product names
    final products = await _firestore
        .collection(FirestoreCollections.products)
        .where('isActive', isEqualTo: true)
        .where('isPopular', isEqualTo: true)
        .limit(50)
        .get();

    for (final doc in products.docs) {
      final data = doc.data();
      final nameEn = data['nameEn'] as String? ?? '';
      final nameAr = data['nameAr'] as String? ?? '';

      if (nameEn.toLowerCase().contains(lowerQuery)) {
        suggestions.add(nameEn);
      }
      if (nameAr.contains(query)) {
        suggestions.add(nameAr);
      }

      if (suggestions.length >= limit) break;
    }

    return suggestions.take(limit).toList();
  }
}
