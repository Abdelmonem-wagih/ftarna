import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_entity.dart';

/// Product model for Firestore mapping
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.restaurantId,
    required super.categoryId,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.price,
    super.discountedPrice,
    super.imageUrl,
    super.imageUrls,
    super.isActive,
    super.isAvailable,
    super.branchAvailability,
    super.sortOrder,
    super.variationGroups,
    super.tags,
    super.preparationTimeMinutes,
    super.calories,
    super.isPopular,
    super.isFeatured,
    super.orderCount,
    super.rating,
    super.totalReviews,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create model from Firestore document
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromJson(data, doc.id);
  }

  /// Create model from JSON with ID
  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      restaurantId: json['restaurantId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      isAvailable: json['isAvailable'] as bool? ?? true,
      branchAvailability: (json['branchAvailability'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
      sortOrder: json['sortOrder'] as int? ?? 0,
      variationGroups: (json['variationGroups'] as List<dynamic>?)
              ?.map((v) => VariationGroup.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 15,
      calories: (json['calories'] as num?)?.toDouble(),
      isPopular: json['isPopular'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      orderCount: json['orderCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'discountedPrice': discountedPrice,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'branchAvailability': branchAvailability,
      'sortOrder': sortOrder,
      'variationGroups': variationGroups.map((v) => v.toJson()).toList(),
      'tags': tags,
      'preparationTimeMinutes': preparationTimeMinutes,
      'calories': calories,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'orderCount': orderCount,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      // Searchable fields (lowercase for case-insensitive search)
      'searchKeywords': _generateSearchKeywords(),
    };
  }

  /// Generate search keywords for full-text search
  List<String> _generateSearchKeywords() {
    final keywords = <String>{};

    // Add name keywords
    keywords.addAll(nameAr.toLowerCase().split(' '));
    keywords.addAll(nameEn.toLowerCase().split(' '));

    // Add description keywords
    if (descriptionAr != null) {
      keywords.addAll(descriptionAr!.toLowerCase().split(' '));
    }
    if (descriptionEn != null) {
      keywords.addAll(descriptionEn!.toLowerCase().split(' '));
    }

    // Add tags
    keywords.addAll(tags.map((t) => t.toLowerCase()));

    // Remove empty strings
    keywords.remove('');

    return keywords.toList();
  }

  /// Create model from entity
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      categoryId: entity.categoryId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      price: entity.price,
      discountedPrice: entity.discountedPrice,
      imageUrl: entity.imageUrl,
      imageUrls: entity.imageUrls,
      isActive: entity.isActive,
      isAvailable: entity.isAvailable,
      branchAvailability: entity.branchAvailability,
      sortOrder: entity.sortOrder,
      variationGroups: entity.variationGroups,
      tags: entity.tags,
      preparationTimeMinutes: entity.preparationTimeMinutes,
      calories: entity.calories,
      isPopular: entity.isPopular,
      isFeatured: entity.isFeatured,
      orderCount: entity.orderCount,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
