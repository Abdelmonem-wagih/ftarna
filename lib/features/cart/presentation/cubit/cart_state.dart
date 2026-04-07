part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  CartEntity? get cart => null;

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartEmpty extends CartState {}

class CartLoaded extends CartState {
  @override
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartUpdating extends CartState {
  @override
  final CartEntity? cart;

  const CartUpdating(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
