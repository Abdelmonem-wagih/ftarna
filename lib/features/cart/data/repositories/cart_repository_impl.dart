import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/constants.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../restaurant/domain/entities/restaurant_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';

/// Cart repository implementation
class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;
  static const String _localCartKey = 'local_cart';

  CartRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.carts);

  @override
  Future<CartEntity?> getCart(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (!doc.exists) return null;
    return _cartFromFirestore(doc);
  }

  @override
  Future<CartEntity> saveCart(CartEntity cart) async {
    await _collection.doc(cart.userId).set(_cartToFirestore(cart));
    return cart;
  }

  @override
  Future<CartEntity> addToCart({
    required String userId,
    required ProductEntity product,
    required int quantity,
    required RestaurantEntity restaurant,
    // required BranchEntity branch,
    List<SelectedVariation>? selectedVariations,
    String? specialInstructions,
  }) async {
    var cart = await getCart(userId);

    // Check if adding from different restaurant
    if (cart != null &&
        cart.restaurantId != null &&
        cart.restaurantId != restaurant.id) {
      // Clear cart if different restaurant
      cart = cart.clear().copyWith(
            restaurantId: restaurant.id,
            restaurantNameAr: restaurant.nameAr,
            restaurantNameEn: restaurant.nameEn,
            // branchId: branch.id,
            // branchNameAr: branch.nameAr,
            // branchNameEn: branch.nameEn,
          );
    }

    // Create cart if doesn't exist
    cart ??= CartEntity(
      id: userId,
      userId: userId,
      restaurantId: restaurant.id,
      restaurantNameAr: restaurant.nameAr,
      restaurantNameEn: restaurant.nameEn,
      // branchId: branch.id,
      // branchNameAr: branch.nameAr,
      // branchNameEn: branch.nameEn,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create cart item
    final cartItem = CartItemEntity.fromProduct(
      product: product,
      quantity: quantity,
      selectedVariations: selectedVariations ?? [],
      specialInstructions: specialInstructions,
    );

    // Add item to cart
    cart = cart.addItem(cartItem);

    // Save and return
    await saveCart(cart);
    return cart;
  }

  @override
  Future<CartEntity> updateItemQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    var cart = await getCart(userId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    cart = cart.updateItemQuantity(itemId, quantity);
    await saveCart(cart);
    return cart;
  }

  @override
  Future<CartEntity> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    var cart = await getCart(userId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    cart = cart.removeItem(itemId);
    await saveCart(cart);
    return cart;
  }

  @override
  Future<void> clearCart(String userId) async {
    await _collection.doc(userId).delete();
  }

  @override
  Future<CartEntity> applyDiscountCode({
    required String userId,
    required String code,
  }) async {
    var cart = await getCart(userId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    // Verify discount code from offers collection
    final offerSnapshot = await _firestore
        .collection(FirestoreCollections.offers)
        .where('discountCode', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (offerSnapshot.docs.isEmpty) {
      throw Exception('Invalid discount code');
    }

    final offerData = offerSnapshot.docs.first.data();
    final offerId = offerSnapshot.docs.first.id;

    // Check if offer is valid for this restaurant
    final offerRestaurantId = offerData['restaurantId'] as String?;
    if (offerRestaurantId != null && offerRestaurantId != cart.restaurantId) {
      throw Exception('Discount code not valid for this restaurant');
    }

    // Check minimum order amount
    final minAmount = (offerData['minimumOrderAmount'] as num?)?.toDouble();
    if (minAmount != null && cart.subtotal < minAmount) {
      throw Exception('Minimum order amount not met');
    }

    // Calculate discount
    final discountType = offerData['discountType'] as String;
    final discountValue = (offerData['discountValue'] as num).toDouble();
    final maxDiscount = (offerData['maximumDiscountAmount'] as num?)?.toDouble();

    double discount;
    if (discountType == 'percentage') {
      discount = cart.subtotal * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maxDiscount != null && discount > maxDiscount) {
      discount = maxDiscount;
    }

    cart = cart.copyWith(
      discountCode: code.toUpperCase(),
      offerId: offerId,
      discountAmount: discount,
      updatedAt: DateTime.now(),
    );

    await saveCart(cart);
    return cart;
  }

  @override
  Future<CartEntity> removeDiscount(String userId) async {
    var cart = await getCart(userId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    cart = cart.copyWith(
      discountCode: null,
      offerId: null,
      discountAmount: 0,
      updatedAt: DateTime.now(),
    );

    await saveCart(cart);
    return cart;
  }

  @override
  Stream<CartEntity?> streamCart(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _cartFromFirestore(doc);
    });
  }

  @override
  Future<CartEntity?> getLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_localCartKey);
    if (cartJson == null) return null;

    try {
      final data = json.decode(cartJson) as Map<String, dynamic>;
      return _cartFromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLocalCart(CartEntity cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(_cartToJson(cart));
    await prefs.setString(_localCartKey, cartJson);
  }

  @override
  Future<void> clearLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localCartKey);
  }

  @override
  Future<CartEntity?> syncLocalCartToServer(String userId) async {
    final localCart = await getLocalCart();
    if (localCart == null) return null;

    // Update cart with user ID
    final cart = localCart.copyWith(
      id: userId,
      userId: userId,
      updatedAt: DateTime.now(),
    );

    await saveCart(cart);
    await clearLocalCart();
    return cart;
  }

  // Helper methods for Firestore conversion
  CartEntity _cartFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _cartFromJson(data).copyWith(id: doc.id);
  }

  CartEntity _cartFromJson(Map<String, dynamic> json) {
    return CartEntity(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['userId'] as String? ?? '',
      restaurantId: json['restaurantId'] as String?,
      restaurantNameAr: json['restaurantNameAr'] as String?,
      restaurantNameEn: json['restaurantNameEn'] as String?,
      branchId: json['branchId'] as String?,
      branchNameAr: json['branchNameAr'] as String?,
      branchNameEn: json['branchNameEn'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => CartItemEntity.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      discountCode: json['discountCode'] as String?,
      offerId: json['offerId'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> _cartToFirestore(CartEntity cart) {
    return {
      'userId': cart.userId,
      'restaurantId': cart.restaurantId,
      'restaurantNameAr': cart.restaurantNameAr,
      'restaurantNameEn': cart.restaurantNameEn,
      'branchId': cart.branchId,
      'branchNameAr': cart.branchNameAr,
      'branchNameEn': cart.branchNameEn,
      'items': cart.items.map((i) => i.toJson()).toList(),
      'discountCode': cart.discountCode,
      'offerId': cart.offerId,
      'discountAmount': cart.discountAmount,
      'createdAt': Timestamp.fromDate(cart.createdAt),
      'updatedAt': Timestamp.fromDate(cart.updatedAt),
    };
  }

  Map<String, dynamic> _cartToJson(CartEntity cart) {
    return {
      'id': cart.id,
      'userId': cart.userId,
      'restaurantId': cart.restaurantId,
      'restaurantNameAr': cart.restaurantNameAr,
      'restaurantNameEn': cart.restaurantNameEn,
      'branchId': cart.branchId,
      'branchNameAr': cart.branchNameAr,
      'branchNameEn': cart.branchNameEn,
      'items': cart.items.map((i) => i.toJson()).toList(),
      'discountCode': cart.discountCode,
      'offerId': cart.offerId,
      'discountAmount': cart.discountAmount,
      'createdAt': cart.createdAt.toIso8601String(),
      'updatedAt': cart.updatedAt.toIso8601String(),
    };
  }
}
