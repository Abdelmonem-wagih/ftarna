import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../models/menu_item_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _menuCollection =>
      _firestore.collection(FirestoreCollections.menuItems);

  @override
  Stream<List<MenuItemEntity>> get menuItemsStream {
    return _menuCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Stream<List<MenuItemEntity>> get activeMenuItemsStream {
    return _menuCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Future<List<MenuItemEntity>> getMenuItems() async {
    final snapshot = await _menuCollection.orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<MenuItemEntity>> getActiveMenuItems() async {
    final snapshot = await _menuCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt')
        .get();
    return snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<MenuItemEntity?> getMenuItemById(String id) async {
    final doc = await _menuCollection.doc(id).get();
    if (!doc.exists) return null;
    return MenuItemModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<MenuItemEntity> addMenuItem(MenuItemEntity item) async {
    final model = MenuItemModel.fromEntity(item);
    final docRef = await _menuCollection.add(model.toJson());
    return item.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateMenuItem(MenuItemEntity item) async {
    final model = MenuItemModel.fromEntity(item);
    await _menuCollection.doc(item.id).update(model.toJson());
  }

  @override
  Future<void> archiveMenuItem(String id) async {
    await _menuCollection.doc(id).update({'isActive': false});
  }

  @override
  Future<void> activateMenuItem(String id) async {
    await _menuCollection.doc(id).update({'isActive': true});
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await _menuCollection.doc(id).delete();
  }
}
