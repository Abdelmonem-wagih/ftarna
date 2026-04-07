import 'package:equatable/equatable.dart';

/// Branch entity representing a restaurant location
class BranchEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double latitude;
  final double longitude;
  final String addressAr;
  final String addressEn;
  final String? phone;
  final String? email;
  final bool isActive;
  final bool isOpen;
  final Map<String, dynamic>? workingHours;
  final double? deliveryFee;
  final int? estimatedDeliveryMinutes;
  final double? deliveryRadiusKm;
  final List<String> adminIds;
  final double rating;
  final int totalReviews;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BranchEntity({
    required this.id,
    required this.restaurantId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.latitude,
    required this.longitude,
    required this.addressAr,
    required this.addressEn,
    this.phone,
    this.email,
    this.isActive = true,
    this.isOpen = true,
    this.workingHours,
    this.deliveryFee,
    this.estimatedDeliveryMinutes,
    this.deliveryRadiusKm,
    this.adminIds = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalOrders = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get localized name based on locale
  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  /// Get localized address based on locale
  String getLocalizedAddress(String locale) {
    return locale == 'ar' ? addressAr : addressEn;
  }

  /// Get localized description based on locale
  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        latitude,
        longitude,
        addressAr,
        addressEn,
        phone,
        email,
        isActive,
        isOpen,
        workingHours,
        deliveryFee,
        estimatedDeliveryMinutes,
        deliveryRadiusKm,
        adminIds,
        rating,
        totalReviews,
        totalOrders,
        createdAt,
        updatedAt,
      ];

  BranchEntity copyWith({
    String? id,
    String? restaurantId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? latitude,
    double? longitude,
    String? addressAr,
    String? addressEn,
    String? phone,
    String? email,
    bool? isActive,
    bool? isOpen,
    Map<String, dynamic>? workingHours,
    double? deliveryFee,
    int? estimatedDeliveryMinutes,
    double? deliveryRadiusKm,
    List<String>? adminIds,
    double? rating,
    int? totalReviews,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      isOpen: isOpen ?? this.isOpen,
      workingHours: workingHours ?? this.workingHours,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryMinutes:
          estimatedDeliveryMinutes ?? this.estimatedDeliveryMinutes,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      adminIds: adminIds ?? this.adminIds,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
