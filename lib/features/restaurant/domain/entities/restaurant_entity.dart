import 'package:equatable/equatable.dart';

/// Restaurant entity representing a food establishment
class RestaurantEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? logoUrl;
  final String? coverImageUrl;
  final String ownerId;
  final double rating;
  final int totalReviews;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final bool isVerified;
  final List<String> cuisineTypes;
  final Map<String, dynamic>? workingHours;
  final double? minimumOrderAmount;
  final double? deliveryFee;
  final int? estimatedDeliveryMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RestaurantEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.logoUrl,
    this.coverImageUrl,
    required this.ownerId,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
    this.isVerified = false,
    this.cuisineTypes = const [],
    this.workingHours,
    this.minimumOrderAmount,
    this.deliveryFee,
    this.estimatedDeliveryMinutes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get localized name based on locale
  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  /// Get localized description based on locale
  String? getLocalizedDescription(String locale) {
    return locale == 'ar' ? descriptionAr : descriptionEn;
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        descriptionAr,
        descriptionEn,
        logoUrl,
        coverImageUrl,
        ownerId,
        rating,
        totalReviews,
        latitude,
        longitude,
        address,
        phone,
        email,
        isActive,
        isVerified,
        cuisineTypes,
        workingHours,
        minimumOrderAmount,
        deliveryFee,
        estimatedDeliveryMinutes,
        createdAt,
        updatedAt,
      ];

  RestaurantEntity copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? logoUrl,
    String? coverImageUrl,
    String? ownerId,
    double? rating,
    int? totalReviews,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
    bool? isVerified,
    List<String>? cuisineTypes,
    Map<String, dynamic>? workingHours,
    double? minimumOrderAmount,
    double? deliveryFee,
    int? estimatedDeliveryMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      ownerId: ownerId ?? this.ownerId,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      workingHours: workingHours ?? this.workingHours,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryMinutes:
          estimatedDeliveryMinutes ?? this.estimatedDeliveryMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
