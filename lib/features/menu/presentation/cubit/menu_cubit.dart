import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';

// States
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItemEntity> items;
  final Map<String, int> selectedQuantities;

  const MenuLoaded({
    required this.items,
    this.selectedQuantities = const {},
  });

  @override
  List<Object?> get props => [items, selectedQuantities];

  MenuLoaded copyWith({
    List<MenuItemEntity>? items,
    Map<String, int>? selectedQuantities,
  }) {
    return MenuLoaded(
      items: items ?? this.items,
      selectedQuantities: selectedQuantities ?? this.selectedQuantities,
    );
  }

  double get totalPrice {
    double total = 0;
    for (final item in items) {
      final qty = selectedQuantities[item.id] ?? 0;
      total += item.price * qty;
    }
    return total;
  }

  int get totalSelectedItems {
    return selectedQuantities.values.fold(0, (sum, qty) => sum + qty);
  }
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MenuCubit extends Cubit<MenuState> {
  final MenuRepository _menuRepository;
  StreamSubscription? _menuSubscription;

  MenuCubit(this._menuRepository) : super(MenuInitial());

  void loadActiveMenuItems() {
    emit(MenuLoading());
    _menuSubscription?.cancel();
    _menuSubscription = _menuRepository.activeMenuItemsStream.listen(
      (items) {
        final currentState = state;
        final quantities = currentState is MenuLoaded
            ? currentState.selectedQuantities
            : <String, int>{};
        emit(MenuLoaded(items: items, selectedQuantities: quantities));
      },
      onError: (error) {
        emit(MenuError(error.toString()));
      },
    );
  }

  void loadAllMenuItems() {
    emit(MenuLoading());
    _menuSubscription?.cancel();
    _menuSubscription = _menuRepository.menuItemsStream.listen(
      (items) {
        final currentState = state;
        final quantities = currentState is MenuLoaded
            ? currentState.selectedQuantities
            : <String, int>{};
        emit(MenuLoaded(items: items, selectedQuantities: quantities));
      },
      onError: (error) {
        emit(MenuError(error.toString()));
      },
    );
  }

  void incrementQuantity(String itemId) {
    final currentState = state;
    if (currentState is MenuLoaded) {
      final newQuantities = Map<String, int>.from(currentState.selectedQuantities);
      newQuantities[itemId] = (newQuantities[itemId] ?? 0) + 1;
      emit(currentState.copyWith(selectedQuantities: newQuantities));
    }
  }

  void decrementQuantity(String itemId) {
    final currentState = state;
    if (currentState is MenuLoaded) {
      final newQuantities = Map<String, int>.from(currentState.selectedQuantities);
      final currentQty = newQuantities[itemId] ?? 0;
      if (currentQty > 0) {
        newQuantities[itemId] = currentQty - 1;
        if (newQuantities[itemId] == 0) {
          newQuantities.remove(itemId);
        }
        emit(currentState.copyWith(selectedQuantities: newQuantities));
      }
    }
  }

  void setQuantity(String itemId, int quantity) {
    final currentState = state;
    if (currentState is MenuLoaded) {
      final newQuantities = Map<String, int>.from(currentState.selectedQuantities);
      if (quantity > 0) {
        newQuantities[itemId] = quantity;
      } else {
        newQuantities.remove(itemId);
      }
      emit(currentState.copyWith(selectedQuantities: newQuantities));
    }
  }

  void clearSelections() {
    final currentState = state;
    if (currentState is MenuLoaded) {
      emit(currentState.copyWith(selectedQuantities: {}));
    }
  }

  void setSelectionsFromOrder(Map<String, int> quantities) {
    final currentState = state;
    if (currentState is MenuLoaded) {
      emit(currentState.copyWith(selectedQuantities: quantities));
    }
  }

  Future<void> addMenuItem(MenuItemEntity item) async {
    try {
      await _menuRepository.addMenuItem(item);
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> updateMenuItem(MenuItemEntity item) async {
    try {
      await _menuRepository.updateMenuItem(item);
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> archiveMenuItem(String id) async {
    try {
      await _menuRepository.archiveMenuItem(id);
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  Future<void> activateMenuItem(String id) async {
    try {
      await _menuRepository.activateMenuItem(id);
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _menuSubscription?.cancel();
    return super.close();
  }
}
