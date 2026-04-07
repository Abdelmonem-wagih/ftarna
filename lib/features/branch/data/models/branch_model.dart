import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/branch_entity.dart';

/// Branch model for Firestore mapping
class BranchModel extends BranchEntity {
  const BranchModel({
    required super.id,
    required super.restaurantId,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.latitude,
    required super.longitude,
    required super.addressAr,
    required super.addressEn,
    super.phone,
    super.email,
    super.isActive,
    super.isOpen,
    super.workingHours,
    super.deliveryFee,
    super.estimatedDeliveryMinutes,
    super.deliveryRadiusKm,
    super.adminIds,
    super.rating,
    super.totalReviews,
    super.totalOrders,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create model from Firestore document
  factory BranchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BranchModel.fromJson(data, doc.id);
  }

  /// Create model from JSON with ID
  factory BranchModel.fromJson(Map<String, dynamic> json, String id) {
    final location = json['location'] as GeoPoint?;
    return BranchModel(
      id: id,
      restaurantId: json['restaurantId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      latitude: location?.latitude ?? (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: location?.longitude ?? (json['longitude'] as num?)?.toDouble() ?? 0.0,
      addressAr: json['addressAr'] as String? ?? '',
      addressEn: json['addressEn'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isOpen: json['isOpen'] as bool? ?? true,
      workingHours: json['workingHours'] as Map<String, dynamic>?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      estimatedDeliveryMinutes: json['estimatedDeliveryMinutes'] as int?,
      deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toDouble(),
      adminIds: (json['adminIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'location': GeoPoint(latitude, longitude),
      'addressAr': addressAr,
      'addressEn': addressEn,
      'phone': phone,
      'email': email,
      'isActive': isActive,
      'isOpen': isOpen,
      'workingHours': workingHours,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
      'deliveryRadiusKm': deliveryRadiusKm,
      'adminIds': adminIds,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalOrders': totalOrders,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      // GeoHash for geo queries
      'geohash': _calculateGeohash(latitude, longitude),
    };
  }

  /// Create model from entity
  factory BranchModel.fromEntity(BranchEntity entity) {
    return BranchModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      latitude: entity.latitude,
      longitude: entity.longitude,
      addressAr: entity.addressAr,
      addressEn: entity.addressEn,
      phone: entity.phone,
      email: entity.email,
      isActive: entity.isActive,
      isOpen: entity.isOpen,
      workingHours: entity.workingHours,
      deliveryFee: entity.deliveryFee,
      estimatedDeliveryMinutes: entity.estimatedDeliveryMinutes,
      deliveryRadiusKm: entity.deliveryRadiusKm,
      adminIds: entity.adminIds,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      totalOrders: entity.totalOrders,
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
