import 'package:equatable/equatable.dart';

import '../../../../core/utils/constants.dart';

/// Offer entity for discounts and promotions
class OfferEntity extends Equatable {
  final String id;
  final String? restaurantId;
  final String? branchId;
  final String? productId;
  final String? categoryId;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final DiscountType discountType;
  final double discountValue; // Percentage or fixed amount
  final String? discountCode;
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final int? usageLimit; // Total usage limit
  final int? usageLimitPerUser;
  final int usageCount;
  final List<String> applicableProductIds;
  final List<String> applicableCategoryIds;
  final bool isActive;
  final bool requiresCode;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OfferEntity({
    required this.id,
    this.restaurantId,
    this.branchId,
    this.productId,
    this.categoryId,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    required this.discountType,
    required this.discountValue,
    this.discountCode,
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.usageLimit,
    this.usageLimitPerUser,
    this.usageCount = 0,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
    this.isActive = true,
    this.requiresCode = false,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get localized title
  String getLocalizedTitle(String locale) {
    return locale == 'ar' ? titleAr : titleEn;
  }

  /// Get localized description
  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }

  /// Check if offer is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  /// Check if offer has expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if offer has not started yet
  bool get isPending => DateTime.now().isBefore(startDate);

  /// Calculate discount amount for a given subtotal
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;
    if (minimumOrderAmount != null && subtotal < minimumOrderAmount!) return 0;

    double discount;
    switch (discountType) {
      case DiscountType.percentage:
        discount = subtotal * (discountValue / 100);
        break;
      case DiscountType.fixedAmount:
        discount = discountValue;
        break;
      case DiscountType.freeItem:
      case DiscountType.buyOneGetOne:
        discount = 0; // Handled differently
        break;
    }

    if (maximumDiscountAmount != null && discount > maximumDiscountAmount!) {
      discount = maximumDiscountAmount!;
    }

    return discount.clamp(0, subtotal);
  }

  /// Get discount display text
  String getDiscountDisplayText() {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountValue.toStringAsFixed(0)}%';
      case DiscountType.fixedAmount:
        return '${discountValue.toStringAsFixed(0)} EGP';
      case DiscountType.freeItem:
        return 'Free Item';
      case DiscountType.buyOneGetOne:
        return 'Buy 1 Get 1';
    }
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        branchId,
        productId,
        categoryId,
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        imageUrl,
        discountType,
        discountValue,
        discountCode,
        minimumOrderAmount,
        maximumDiscountAmount,
        usageLimit,
        usageLimitPerUser,
        usageCount,
        applicableProductIds,
        applicableCategoryIds,
        isActive,
        requiresCode,
        startDate,
        endDate,
        createdAt,
        updatedAt,
      ];

  OfferEntity copyWith({
    String? id,
    String? restaurantId,
    String? branchId,
    String? productId,
    String? categoryId,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    DiscountType? discountType,
    double? discountValue,
    String? discountCode,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    int? usageLimitPerUser,
    int? usageCount,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    bool? isActive,
    bool? requiresCode,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountCode: discountCode ?? this.discountCode,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount:
          maximumDiscountAmount ?? this.maximumDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageLimitPerUser: usageLimitPerUser ?? this.usageLimitPerUser,
      usageCount: usageCount ?? this.usageCount,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds:
          applicableCategoryIds ?? this.applicableCategoryIds,
      isActive: isActive ?? this.isActive,
      requiresCode: requiresCode ?? this.requiresCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
