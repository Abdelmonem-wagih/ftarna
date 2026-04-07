import 'package:equatable/equatable.dart';

/// Product variation (e.g., size, extras)
class ProductVariation extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final double priceModifier;
  final bool isDefault;

  const ProductVariation({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.priceModifier = 0.0,
    this.isDefault = false,
  });

  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, priceModifier, isDefault];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'priceModifier': priceModifier,
      'isDefault': isDefault,
    };
  }

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

/// Product variation group (e.g., Size, Extras, Add-ons)
class VariationGroup extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final bool isRequired;
  final bool allowMultiple;
  final int? maxSelections;
  final List<ProductVariation> variations;

  const VariationGroup({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isRequired = false,
    this.allowMultiple = false,
    this.maxSelections,
    this.variations = const [],
  });

  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        isRequired,
        allowMultiple,
        maxSelections,
        variations,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'isRequired': isRequired,
      'allowMultiple': allowMultiple,
      'maxSelections': maxSelections,
      'variations': variations.map((v) => v.toJson()).toList(),
    };
  }

  factory VariationGroup.fromJson(Map<String, dynamic> json) {
    return VariationGroup(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
      allowMultiple: json['allowMultiple'] as bool? ?? false,
      maxSelections: json['maxSelections'] as int?,
      variations: (json['variations'] as List<dynamic>?)
              ?.map((v) => ProductVariation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Product entity with full details
class ProductEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final double? discountedPrice;
  final String? imageUrl;
  final List<String> imageUrls;
  final bool isActive;
  final bool isAvailable;
  final Map<String, bool> branchAvailability; // branchId -> isAvailable
  final int sortOrder;
  final List<VariationGroup> variationGroups;
  final List<String> tags;
  final int preparationTimeMinutes;
  final double? calories;
  final bool isPopular;
  final bool isFeatured;
  final int orderCount;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.discountedPrice,
    this.imageUrl,
    this.imageUrls = const [],
    this.isActive = true,
    this.isAvailable = true,
    this.branchAvailability = const {},
    this.sortOrder = 0,
    this.variationGroups = const [],
    this.tags = const [],
    this.preparationTimeMinutes = 15,
    this.calories,
    this.isPopular = false,
    this.isFeatured = false,
    this.orderCount = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
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

  /// Check if product is available at a specific branch
  bool isAvailableAtBranch(String branchId) {
    return isAvailable && (branchAvailability[branchId] ?? true);
  }

  /// Get effective price (discounted or regular)
  double get effectivePrice => discountedPrice ?? price;

  /// Check if product has a discount
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountedPrice!) / price * 100).roundToDouble();
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        categoryId,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        price,
        discountedPrice,
        imageUrl,
        imageUrls,
        isActive,
        isAvailable,
        branchAvailability,
        sortOrder,
        variationGroups,
        tags,
        preparationTimeMinutes,
        calories,
        isPopular,
        isFeatured,
        orderCount,
        rating,
        totalReviews,
        createdAt,
        updatedAt,
      ];

  ProductEntity copyWith({
    String? id,
    String? restaurantId,
    String? categoryId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? discountedPrice,
    String? imageUrl,
    List<String>? imageUrls,
    bool? isActive,
    bool? isAvailable,
    Map<String, bool>? branchAvailability,
    int? sortOrder,
    List<VariationGroup>? variationGroups,
    List<String>? tags,
    int? preparationTimeMinutes,
    double? calories,
    bool? isPopular,
    bool? isFeatured,
    int? orderCount,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      branchAvailability: branchAvailability ?? this.branchAvailability,
      sortOrder: sortOrder ?? this.sortOrder,
      variationGroups: variationGroups ?? this.variationGroups,
      tags: tags ?? this.tags,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      calories: calories ?? this.calories,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      orderCount: orderCount ?? this.orderCount,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
