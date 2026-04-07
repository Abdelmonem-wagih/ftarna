import 'package:equatable/equatable.dart';

import '../../../order/domain/entities/order_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

/// Cart item entity
class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productNameAr;
  final String productNameEn;
  final String? imageUrl;
  final double basePrice;
  final int quantity;
  final List<SelectedVariation> selectedVariations;
  final String? specialInstructions;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    this.imageUrl,
    required this.basePrice,
    required this.quantity,
    this.selectedVariations = const [],
    this.specialInstructions,
    required this.addedAt,
  });

  /// Get localized name
  String getLocalizedName(String locale) {
    return locale == 'ar' ? productNameAr : productNameEn;
  }

  /// Calculate total variation price modifier
  double get variationsPrice =>
      selectedVariations.fold(0.0, (sum, v) => sum + v.priceModifier);

  /// Unit price including variations
  double get unitPrice => basePrice + variationsPrice;

  /// Total price for this item
  double get totalPrice => unitPrice * quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        productNameAr,
        productNameEn,
        imageUrl,
        basePrice,
        quantity,
        selectedVariations,
        specialInstructions,
        addedAt,
      ];

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? productNameAr,
    String? productNameEn,
    String? imageUrl,
    double? basePrice,
    int? quantity,
    List<SelectedVariation>? selectedVariations,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productNameAr: productNameAr ?? this.productNameAr,
      productNameEn: productNameEn ?? this.productNameEn,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Create from product entity
  factory CartItemEntity.fromProduct({
    required ProductEntity product,
    required int quantity,
    List<SelectedVariation> selectedVariations = const [],
    String? specialInstructions,
  }) {
    return CartItemEntity(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productNameAr: product.nameAr,
      productNameEn: product.nameEn,
      imageUrl: product.imageUrl,
      basePrice: product.effectivePrice,
      quantity: quantity,
      selectedVariations: selectedVariations,
      specialInstructions: specialInstructions,
      addedAt: DateTime.now(),
    );
  }

  /// Convert to order item
  OrderItemEntity toOrderItem() {
    return OrderItemEntity(
      id: id,
      productId: productId,
      nameAr: productNameAr,
      nameEn: productNameEn,
      imageUrl: imageUrl,
      basePrice: basePrice,
      quantity: quantity,
      selectedVariations: selectedVariations,
      specialInstructions: specialInstructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productNameAr': productNameAr,
      'productNameEn': productNameEn,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'quantity': quantity,
      'selectedVariations': selectedVariations.map((v) => v.toJson()).toList(),
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productNameAr: json['productNameAr'] as String,
      productNameEn: json['productNameEn'] as String,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedVariations: (json['selectedVariations'] as List<dynamic>?)
              ?.map(
                  (v) => SelectedVariation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

/// Cart entity for managing user's shopping cart
class CartEntity extends Equatable {
  final String id;
  final String userId;
  final String? restaurantId;
  final String? restaurantNameAr;
  final String? restaurantNameEn;
  final String? branchId;
  final String? branchNameAr;
  final String? branchNameEn;
  final List<CartItemEntity> items;
  final String? discountCode;
  final String? offerId;
  final double discountAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    this.restaurantId,
    this.restaurantNameAr,
    this.restaurantNameEn,
    this.branchId,
    this.branchNameAr,
    this.branchNameEn,
    this.items = const [],
    this.discountCode,
    this.offerId,
    this.discountAmount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal before discount
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Total after discount
  double get total => (subtotal - discountAmount).clamp(0, double.infinity);

  /// Get localized restaurant name
  String? getLocalizedRestaurantName(String locale) {
    if (restaurantNameAr == null || restaurantNameEn == null) return null;
    return locale == 'ar' ? restaurantNameAr : restaurantNameEn;
  }

  /// Get localized branch name
  String? getLocalizedBranchName(String locale) {
    if (branchNameAr == null || branchNameEn == null) return null;
    return locale == 'ar' ? branchNameAr : branchNameEn;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurantId,
        restaurantNameAr,
        restaurantNameEn,
        branchId,
        branchNameAr,
        branchNameEn,
        items,
        discountCode,
        offerId,
        discountAmount,
        createdAt,
        updatedAt,
      ];

  CartEntity copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantNameAr,
    String? restaurantNameEn,
    String? branchId,
    String? branchNameAr,
    String? branchNameEn,
    List<CartItemEntity>? items,
    String? discountCode,
    String? offerId,
    double? discountAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantNameAr: restaurantNameAr ?? this.restaurantNameAr,
      restaurantNameEn: restaurantNameEn ?? this.restaurantNameEn,
      branchId: branchId ?? this.branchId,
      branchNameAr: branchNameAr ?? this.branchNameAr,
      branchNameEn: branchNameEn ?? this.branchNameEn,
      items: items ?? this.items,
      discountCode: discountCode ?? this.discountCode,
      offerId: offerId ?? this.offerId,
      discountAmount: discountAmount ?? this.discountAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add item to cart
  CartEntity addItem(CartItemEntity item) {
    final existingIndex = items.indexWhere(
      (i) =>
          i.productId == item.productId &&
          _variationsMatch(i.selectedVariations, item.selectedVariations),
    );

    List<CartItemEntity> newItems;
    if (existingIndex != -1) {
      // Update quantity of existing item
      newItems = List.from(items);
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + item.quantity,
      );
    } else {
      newItems = [...items, item];
    }

    return copyWith(items: newItems, updatedAt: DateTime.now());
  }

  /// Update item quantity
  CartEntity updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      return removeItem(itemId);
    }

    final newItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return copyWith(items: newItems, updatedAt: DateTime.now());
  }

  /// Remove item from cart
  CartEntity removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: newItems, updatedAt: DateTime.now());
  }

  /// Clear cart
  CartEntity clear() {
    return copyWith(
      items: [],
      discountCode: null,
      offerId: null,
      discountAmount: 0,
      updatedAt: DateTime.now(),
    );
  }

  bool _variationsMatch(
    List<SelectedVariation> a,
    List<SelectedVariation> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].variationId != b[i].variationId) return false;
    }
    return true;
  }
}
