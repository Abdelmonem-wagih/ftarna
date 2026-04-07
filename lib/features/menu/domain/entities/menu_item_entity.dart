import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final bool isActive;
  final DateTime createdAt;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.price,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, price, isActive, createdAt];

  MenuItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
