import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/restaurant_entity.dart';

/// Restaurant model for Firestore mapping
class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    super.logoUrl,
    super.coverImageUrl,
    required super.ownerId,
    super.rating,
    super.totalReviews,
    required super.latitude,
    required super.longitude,
    super.address,
    super.phone,
    super.email,
    super.isActive,
    super.isVerified,
    super.cuisineTypes,
    super.workingHours,
    super.minimumOrderAmount,
    super.deliveryFee,
    super.estimatedDeliveryMinutes,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create model from Firestore document
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel.fromJson(data, doc.id);
  }

  /// Create model from JSON with ID
  factory RestaurantModel.fromJson(Map<String, dynamic> json, String id) {
    final location = json['location'] as GeoPoint?;
    return RestaurantModel(
      id: id,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      latitude: location?.latitude ?? (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: location?.longitude ?? (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      cuisineTypes: (json['cuisineTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workingHours: json['workingHours'] as Map<String, dynamic>?,
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      estimatedDeliveryMinutes: json['estimatedDeliveryMinutes'] as int?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'ownerId': ownerId,
      'rating': rating,
      'totalReviews': totalReviews,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'phone': phone,
      'email': email,
      'isActive': isActive,
      'isVerified': isVerified,
      'cuisineTypes': cuisineTypes,
      'workingHours': workingHours,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      // GeoHash for geo queries
      'geohash': _calculateGeohash(latitude, longitude),
    };
  }

  /// Create model from entity
  factory RestaurantModel.fromEntity(RestaurantEntity entity) {
    return RestaurantModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      logoUrl: entity.logoUrl,
      coverImageUrl: entity.coverImageUrl,
      ownerId: entity.ownerId,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      cuisineTypes: entity.cuisineTypes,
      workingHours: entity.workingHours,
      minimumOrderAmount: entity.minimumOrderAmount,
      deliveryFee: entity.deliveryFee,
      estimatedDeliveryMinutes: entity.estimatedDeliveryMinutes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Simple geohash calculation for geo queries
  static String _calculateGeohash(double lat, double lng) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    var hash = StringBuffer();
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (hash.length < 9) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (lng > mid) {
          ch |= (1 << (4 - bit));
          minLng = mid;
        } else {
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (lat > mid) {
          ch |= (1 << (4 - bit));
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        hash.write(base32[ch]);
        bit = 0;
        ch = 0;
      }
    }
    return hash.toString();
  }
}
