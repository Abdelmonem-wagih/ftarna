import 'package:equatable/equatable.dart';

/// Review entity for rating restaurants/branches/products
class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? restaurantId;
  final String? branchId;
  final String? productId;
  final String? orderId;
  final double rating;
  final String? comment;
  final List<String> imageUrls;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> helpfulByUserIds;
  final bool isVisible;
  final String? adminReply;
  final DateTime? adminReplyAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.restaurantId,
    this.branchId,
    this.productId,
    this.orderId,
    required this.rating,
    this.comment,
    this.imageUrls = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.helpfulByUserIds = const [],
    this.isVisible = true,
    this.adminReply,
    this.adminReplyAt,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhotoUrl,
        restaurantId,
        branchId,
        productId,
        orderId,
        rating,
        comment,
        imageUrls,
        isVerifiedPurchase,
        helpfulCount,
        helpfulByUserIds,
        isVisible,
        adminReply,
        adminReplyAt,
        createdAt,
        updatedAt,
      ];

  ReviewEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? restaurantId,
    String? branchId,
    String? productId,
    String? orderId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    List<String>? helpfulByUserIds,
    bool? isVisible,
    String? adminReply,
    DateTime? adminReplyAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulByUserIds: helpfulByUserIds ?? this.helpfulByUserIds,
      isVisible: isVisible ?? this.isVisible,
      adminReply: adminReply ?? this.adminReply,
      adminReplyAt: adminReplyAt ?? this.adminReplyAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Rating summary for restaurants/branches/products
class RatingSummary extends Equatable {
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  const RatingSummary({
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
  });

  /// Get percentage for a specific star rating
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0;
    int count;
    switch (stars) {
      case 5:
        count = fiveStarCount;
        break;
      case 4:
        count = fourStarCount;
        break;
      case 3:
        count = threeStarCount;
        break;
      case 2:
        count = twoStarCount;
        break;
      case 1:
        count = oneStarCount;
        break;
      default:
        return 0;
    }
    return (count / totalReviews) * 100;
  }

  @override
  List<Object?> get props => [
        averageRating,
        totalReviews,
        fiveStarCount,
        fourStarCount,
        threeStarCount,
        twoStarCount,
        oneStarCount,
      ];

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      fiveStarCount: json['fiveStarCount'] as int? ?? 0,
      fourStarCount: json['fourStarCount'] as int? ?? 0,
      threeStarCount: json['threeStarCount'] as int? ?? 0,
      twoStarCount: json['twoStarCount'] as int? ?? 0,
      oneStarCount: json['oneStarCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fiveStarCount': fiveStarCount,
      'fourStarCount': fourStarCount,
      'threeStarCount': threeStarCount,
      'twoStarCount': twoStarCount,
      'oneStarCount': oneStarCount,
    };
  }
}
