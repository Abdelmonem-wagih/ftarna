import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

/// Product repository implementation using Firestore
class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.products);

  @override
  Future<List<ProductEntity>> getProductsByRestaurant(String restaurantId) async {
    final snapshot = await _collection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    final snapshot = await _collection
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<List<ProductEntity>> searchProducts({
    required String query,
    String? restaurantId,
    String? categoryId,
  }) async {
    final lowerQuery = query.toLowerCase();

    Query<Map<String, dynamic>> baseQuery = _collection
        .where('isActive', isEqualTo: true);

    if (restaurantId != null) {
      baseQuery = baseQuery.where('restaurantId', isEqualTo: restaurantId);
    }

    if (categoryId != null) {
      baseQuery = baseQuery.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await baseQuery.get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) {
          return p.nameEn.toLowerCase().contains(lowerQuery) ||
              p.nameAr.contains(query) ||
              (p.descriptionEn?.toLowerCase().contains(lowerQuery) ?? false) ||
              (p.descriptionAr?.contains(query) ?? false) ||
              p.tags.any((t) => t.toLowerCase().contains(lowerQuery));
        })
        .toList();
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts({
    String? restaurantId,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true);

    if (restaurantId != null) {
      query = query.where('restaurantId', isEqualTo: restaurantId);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ProductEntity>> getPopularProducts({
    String? restaurantId,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('isActive', isEqualTo: true)
        .where('isPopular', isEqualTo: true)
        .orderBy('orderCount', descending: true);

    if (restaurantId != null) {
      query = query.where('restaurantId', isEqualTo: restaurantId);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    final docRef = await _collection.add(model.toFirestore());

    // Update category product count
    await _firestore
        .collection(FirestoreCollections.categories)
        .doc(product.categoryId)
        .update({'productCount': FieldValue.increment(1)});

    return model.copyWith(id: docRef.id) as ProductModel;
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    await _collection.doc(product.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      final categoryId = data['categoryId'] as String?;

      // Soft delete
      await _collection.doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update category product count
      if (categoryId != null) {
        await _firestore
            .collection(FirestoreCollections.categories)
            .doc(categoryId)
            .update({'productCount': FieldValue.increment(-1)});
      }
    }
  }

  @override
  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    await _collection.doc(productId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleBranchAvailability(
    String productId,
    String branchId,
    bool isAvailable,
  ) async {
    await _collection.doc(productId).update({
      'branchAvailability.$branchId': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ProductEntity>> streamProducts(String restaurantId) {
    return _collection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<ProductEntity>> streamProductsByCategory(String categoryId) {
    return _collection
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<ProductEntity?> streamProduct(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    });
  }

  @override
  Future<void> incrementOrderCount(String productId) async {
    await _collection.doc(productId).update({
      'orderCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> updateRating(
    String productId,
    double newRating,
    int totalReviews,
  ) async {
    await _collection.doc(productId).update({
      'rating': newRating,
      'totalReviews': totalReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<ProductEntity>> batchCreateProducts(List<ProductEntity> products) async {
    final batch = _firestore.batch();
    final createdProducts = <ProductEntity>[];
    final categoryUpdates = <String, int>{};

    for (final product in products) {
      final model = ProductModel.fromEntity(product);
      final docRef = _collection.doc();
      batch.set(docRef, model.toFirestore());
      createdProducts.add(model.copyWith(id: docRef.id) as ProductModel);

      // Track category counts
      categoryUpdates[product.categoryId] =
          (categoryUpdates[product.categoryId] ?? 0) + 1;
    }

    // Update category counts
    for (final entry in categoryUpdates.entries) {
      final categoryRef = _firestore
          .collection(FirestoreCollections.categories)
          .doc(entry.key);
      batch.update(categoryRef, {'productCount': FieldValue.increment(entry.value)});
    }

    await batch.commit();
    return createdProducts;
  }
}
