import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

/// Category repository implementation using Firestore
class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.categories);

  @override
  Future<List<CategoryEntity>> getCategoriesByRestaurant(
      String restaurantId) async {
    final snapshot = await _collection
        .where('restaurantId', isEqualTo: restaurantId)

        .orderBy('sortOrder')
        .get();

    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromFirestore(doc);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final docRef = await _collection.add(model.toFirestore());
    return model.copyWith(id: docRef.id) as CategoryModel;
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _collection.doc(category.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Soft delete
    await _collection.doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    final batch = _firestore.batch();

    for (var i = 0; i < categoryIds.length; i++) {
      batch.update(_collection.doc(categoryIds[i]), {
        'sortOrder': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Stream<List<CategoryEntity>> streamCategories(String restaurantId) {
    return _collection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  @override
  Future<List<CategoryEntity>> batchCreateCategories(
      List<CategoryEntity> categories) async {
    final batch = _firestore.batch();
    final createdCategories = <CategoryEntity>[];

    for (final category in categories) {
      final model = CategoryModel.fromEntity(category);
      final docRef = _collection.doc();
      batch.set(docRef, model.toFirestore());
      createdCategories.add(model.copyWith(id: docRef.id) as CategoryModel);
    }

    await batch.commit();
    return createdCategories;
  }
}
