import 'package:equatable/equatable.dart';

import '../../../../core/utils/constants.dart';

/// Delivery address for user
class DeliveryAddress extends Equatable {
  final String id;
  final String label;
  final String addressLine;
  final String? buildingName;
  final String? floor;
  final String? apartment;
  final String? instructions;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    this.buildingName,
    this.floor,
    this.apartment,
    this.instructions,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        label,
        addressLine,
        buildingName,
        floor,
        apartment,
        instructions,
        latitude,
        longitude,
        isDefault,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'addressLine': addressLine,
      'buildingName': buildingName,
      'floor': floor,
      'apartment': apartment,
      'instructions': instructions,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      addressLine: json['addressLine'] as String,
      buildingName: json['buildingName'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      instructions: json['instructions'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String? restaurantId; // For restaurant admin
  final String? branchId; // For branch admin
  final List<String> fcmTokens;
  final double? lastLatitude;
  final double? lastLongitude;
  final List<String> favoriteRestaurantIds;
  final List<String> favoriteProductIds;
  final List<DeliveryAddress> deliveryAddresses;
  final String preferredLocale;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    this.role = UserRole.user,
    this.restaurantId,
    this.branchId,
    this.fcmTokens = const [],
    this.lastLatitude,
    this.lastLongitude,
    this.favoriteRestaurantIds = const [],
    this.favoriteProductIds = const [],
    this.deliveryAddresses = const [],
    this.preferredLocale = 'en',
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  /// Legacy getter for backward compatibility
  bool get isAdmin => role != UserRole.user;

  /// Check if user is a super admin
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Check if user is a restaurant admin
  bool get isRestaurantAdmin =>
      role == UserRole.restaurantAdmin || role == UserRole.superAdmin;

  /// Check if user is a branch admin
  bool get isBranchAdmin =>
      role == UserRole.branchAdmin ||
      role == UserRole.restaurantAdmin ||
      role == UserRole.superAdmin;

  /// Check if user can manage a specific restaurant
  bool canManageRestaurant(String restaurantId) {
    if (isSuperAdmin) return true;
    if (role == UserRole.restaurantAdmin) {
      return this.restaurantId == restaurantId;
    }
    return false;
  }

  /// Check if user can manage a specific branch
  bool canManageBranch(String branchId) {
    if (isSuperAdmin || role == UserRole.restaurantAdmin) return true;
    if (role == UserRole.branchAdmin) {
      return this.branchId == branchId;
    }
    return false;
  }

  /// Get default delivery address
  DeliveryAddress? get defaultDeliveryAddress {
    try {
      return deliveryAddresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return deliveryAddresses.isNotEmpty ? deliveryAddresses.first : null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        photoUrl,
        role,
        restaurantId,
        branchId,
        fcmTokens,
        lastLatitude,
        lastLongitude,
        favoriteRestaurantIds,
        favoriteProductIds,
        deliveryAddresses,
        preferredLocale,
        notificationsEnabled,
        emailNotificationsEnabled,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    UserRole? role,
    String? restaurantId,
    String? branchId,
    List<String>? fcmTokens,
    double? lastLatitude,
    double? lastLongitude,
    List<String>? favoriteRestaurantIds,
    List<String>? favoriteProductIds,
    List<DeliveryAddress>? deliveryAddresses,
    String? preferredLocale,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      branchId: branchId ?? this.branchId,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      favoriteRestaurantIds:
          favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
