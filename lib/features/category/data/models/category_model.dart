import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_entity.dart';

/// Category model for Firestore mapping
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.restaurantId,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    super.imageUrl,
    super.sortOrder,
    super.isActive,
    super.productCount,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create model from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromJson(data, doc.id);
  }

  /// Create model from JSON with ID
  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      restaurantId: json['restaurantId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      imageUrl: json['imageUrl'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      productCount: json['productCount'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create model from entity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      imageUrl: entity.imageUrl,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      productCount: entity.productCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
