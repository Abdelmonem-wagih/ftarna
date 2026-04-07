import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../restaurant/domain/entities/restaurant_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;
  StreamSubscription? _cartSubscription;
  String? _currentUserId;

  CartCubit(this._cartRepository) : super(CartInitial());

  /// Initialize cart for user
  Future<void> initializeCart(String? userId) async {
    emit(CartLoading());
    try {
      _currentUserId = userId;

      if (userId != null) {
        // Try to sync local cart to server
        await _cartRepository.syncLocalCartToServer(userId);

        // Start listening to cart changes
        _cartSubscription?.cancel();
        _cartSubscription = _cartRepository.streamCart(userId).listen(
          (cart) {
            if (cart != null) {
              emit(CartLoaded(cart));
            } else {
              emit(CartEmpty());
            }
          },
          onError: (error) {
            emit(CartError(error.toString()));
          },
        );
      } else {
        // Load local cart for guest
        final localCart = await _cartRepository.getLocalCart();
        if (localCart != null && localCart.isNotEmpty) {
          emit(CartLoaded(localCart));
        } else {
          emit(CartEmpty());
        }
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required ProductEntity product,
    required int quantity,
    required RestaurantEntity restaurant,
    // required BranchEntity branch,
    List<SelectedVariation>? selectedVariations,
    String? specialInstructions,
  }) async {
    try {
      emit(CartUpdating(state.cart));

      CartEntity updatedCart;

      if (_currentUserId != null) {
        updatedCart = await _cartRepository.addToCart(
          userId: _currentUserId!,
          product: product,
          quantity: quantity,
          restaurant: restaurant,
          // branch: branch,
          selectedVariations: selectedVariations,
          specialInstructions: specialInstructions,
        );
      } else {
        // Handle local cart for guests
        var cart = await _cartRepository.getLocalCart();

        // Check if different restaurant
        if (cart != null &&
            cart.restaurantId != null &&
            cart.restaurantId != restaurant.id) {
          cart = cart.clear();
        }

        cart ??= CartEntity(
          id: 'local',
          userId: '',
          restaurantId: restaurant.id,
          restaurantNameAr: restaurant.nameAr,
          restaurantNameEn: restaurant.nameEn,
          // branchId: branch.id,
          // branchNameAr: branch.nameAr,
          // branchNameEn: branch.nameEn,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final cartItem = CartItemEntity.fromProduct(
          product: product,
          quantity: quantity,
          selectedVariations: selectedVariations ?? [],
          specialInstructions: specialInstructions,
        );

        updatedCart = cart.addItem(cartItem);
        await _cartRepository.saveLocalCart(updatedCart);
      }

      emit(CartLoaded(updatedCart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (state.cart == null) return;

    try {
      emit(CartUpdating(state.cart));

      CartEntity updatedCart;

      if (_currentUserId != null) {
        updatedCart = await _cartRepository.updateItemQuantity(
          userId: _currentUserId!,
          itemId: itemId,
          quantity: quantity,
        );
      } else {
        updatedCart = state.cart!.updateItemQuantity(itemId, quantity);
        await _cartRepository.saveLocalCart(updatedCart);
      }

      if (updatedCart.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(updatedCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    if (state.cart == null) return;

    try {
      emit(CartUpdating(state.cart));

      CartEntity updatedCart;

      if (_currentUserId != null) {
        updatedCart = await _cartRepository.removeFromCart(
          userId: _currentUserId!,
          itemId: itemId,
        );
      } else {
        updatedCart = state.cart!.removeItem(itemId);
        await _cartRepository.saveLocalCart(updatedCart);
      }

      if (updatedCart.isEmpty) {
        emit(CartEmpty());
      } else {
        emit(CartLoaded(updatedCart));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    try {
      emit(CartUpdating(state.cart));

      if (_currentUserId != null) {
        await _cartRepository.clearCart(_currentUserId!);
      } else {
        await _cartRepository.clearLocalCart();
      }

      emit(CartEmpty());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Apply discount code
  Future<void> applyDiscountCode(String code) async {
    if (_currentUserId == null || state.cart == null) return;

    try {
      emit(CartUpdating(state.cart));

      final updatedCart = await _cartRepository.applyDiscountCode(
        userId: _currentUserId!,
        code: code,
      );

      emit(CartLoaded(updatedCart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Remove discount
  Future<void> removeDiscount() async {
    if (_currentUserId == null || state.cart == null) return;

    try {
      emit(CartUpdating(state.cart));

      final updatedCart = await _cartRepository.removeDiscount(_currentUserId!);

      emit(CartLoaded(updatedCart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Remove discount code (alias for removeDiscount)
  Future<void> removeDiscountCode() => removeDiscount();

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
