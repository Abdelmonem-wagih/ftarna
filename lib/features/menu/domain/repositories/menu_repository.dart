import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Stream<List<MenuItemEntity>> get menuItemsStream;
  Stream<List<MenuItemEntity>> get activeMenuItemsStream;
  Future<List<MenuItemEntity>> getMenuItems();
  Future<List<MenuItemEntity>> getActiveMenuItems();
  Future<MenuItemEntity?> getMenuItemById(String id);
  Future<MenuItemEntity> addMenuItem(MenuItemEntity item);
  Future<void> updateMenuItem(MenuItemEntity item);
  Future<void> archiveMenuItem(String id);
  Future<void> activateMenuItem(String id);
  Future<void> deleteMenuItem(String id);
}
