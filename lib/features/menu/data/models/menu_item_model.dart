import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.price,
    super.isActive,
    required super.createdAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      price: price,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
