import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    super.role,
    super.restaurantId,
    super.branchId,
    super.fcmTokens,
    super.lastLatitude,
    super.lastLongitude,
    super.favoriteRestaurantIds,
    super.favoriteProductIds,
    super.deliveryAddresses,
    super.preferredLocale,
    super.notificationsEnabled,
    super.emailNotificationsEnabled,
    required super.createdAt,
    super.updatedAt,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse role
    UserRole role = UserRole.user;
    final roleStr = json['role'] as String?;
    if (roleStr != null) {
      role = UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.user,
      );
    } else if (json['isAdmin'] == true) {
      // Legacy support
      role = UserRole.branchAdmin;
    }

    // Parse delivery addresses
    final addressesList = json['deliveryAddresses'] as List<dynamic>?;
    final addresses = addressesList
            ?.map((a) => DeliveryAddress.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: role,
      restaurantId: json['restaurantId'] as String?,
      branchId: json['branchId'] as String?,
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      lastLatitude: (json['lastLatitude'] as num?)?.toDouble(),
      lastLongitude: (json['lastLongitude'] as num?)?.toDouble(),
      favoriteRestaurantIds: (json['favoriteRestaurantIds'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      favoriteProductIds: (json['favoriteProductIds'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          [],
      deliveryAddresses: addresses,
      preferredLocale: json['preferredLocale'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.name,
      'restaurantId': restaurantId,
      'branchId': branchId,
      'fcmTokens': fcmTokens,
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'favoriteRestaurantIds': favoriteRestaurantIds,
      'favoriteProductIds': favoriteProductIds,
      'deliveryAddresses': deliveryAddresses.map((a) => a.toJson()).toList(),
      'preferredLocale': preferredLocale,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      // Legacy support
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      role: entity.role,
      restaurantId: entity.restaurantId,
      branchId: entity.branchId,
      fcmTokens: entity.fcmTokens,
      lastLatitude: entity.lastLatitude,
      lastLongitude: entity.lastLongitude,
      favoriteRestaurantIds: entity.favoriteRestaurantIds,
      favoriteProductIds: entity.favoriteProductIds,
      deliveryAddresses: entity.deliveryAddresses,
      preferredLocale: entity.preferredLocale,
      notificationsEnabled: entity.notificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      role: role,
      restaurantId: restaurantId,
      branchId: branchId,
      fcmTokens: fcmTokens,
      lastLatitude: lastLatitude,
      lastLongitude: lastLongitude,
      favoriteRestaurantIds: favoriteRestaurantIds,
      favoriteProductIds: favoriteProductIds,
      deliveryAddresses: deliveryAddresses,
      preferredLocale: preferredLocale,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
