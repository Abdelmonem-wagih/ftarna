import 'package:equatable/equatable.dart';

/// Category entity for organizing products
class CategoryEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.restaurantId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get localized name based on locale
  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  /// Get localized description based on locale
  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        imageUrl,
        sortOrder,
        isActive,
        productCount,
        createdAt,
        updatedAt,
      ];

  CategoryEntity copyWith({
    String? id,
    String? restaurantId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
