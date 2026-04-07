import 'package:equatable/equatable.dart';

import '../../../../core/utils/constants.dart';
import '../../../product/domain/entities/product_entity.dart';

/// Selected variation in an order item
class SelectedVariation extends Equatable {
  final String groupId;
  final String groupNameAr;
  final String groupNameEn;
  final String variationId;
  final String variationNameAr;
  final String variationNameEn;
  final double priceModifier;

  const SelectedVariation({
    required this.groupId,
    required this.groupNameAr,
    required this.groupNameEn,
    required this.variationId,
    required this.variationNameAr,
    required this.variationNameEn,
    required this.priceModifier,
  });

  String getLocalizedGroupName(String locale) {
    return locale == 'ar' ? groupNameAr : groupNameEn;
  }

  String getLocalizedVariationName(String locale) {
    return locale == 'ar' ? variationNameAr : variationNameEn;
  }

  @override
  List<Object?> get props => [
        groupId,
        groupNameAr,
        groupNameEn,
        variationId,
        variationNameAr,
        variationNameEn,
        priceModifier,
      ];

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupNameAr': groupNameAr,
      'groupNameEn': groupNameEn,
      'variationId': variationId,
      'variationNameAr': variationNameAr,
      'variationNameEn': variationNameEn,
      'priceModifier': priceModifier,
    };
  }

  factory SelectedVariation.fromJson(Map<String, dynamic> json) {
    return SelectedVariation(
      groupId: json['groupId'] as String,
      groupNameAr: json['groupNameAr'] as String,
      groupNameEn: json['groupNameEn'] as String,
      variationId: json['variationId'] as String,
      variationNameAr: json['variationNameAr'] as String,
      variationNameEn: json['variationNameEn'] as String,
      priceModifier: (json['priceModifier'] as num).toDouble(),
    );
  }
}

class OrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final double basePrice;
  final int quantity;
  final List<SelectedVariation> selectedVariations;
  final String? specialInstructions;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.basePrice,
    required this.quantity,
    this.selectedVariations = const [],
    this.specialInstructions,
  });

  /// Legacy getter for backward compatibility
  String get itemId => productId;

  /// Legacy getter for backward compatibility
  String get name => nameEn;

  /// Legacy getter for backward compatibility
  double get price => unitPrice;

  /// Get localized name
  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  /// Calculate total variation price modifier
  double get variationsPrice =>
      selectedVariations.fold(0.0, (sum, v) => sum + v.priceModifier);

  /// Unit price including variations
  double get unitPrice => basePrice + variationsPrice;

  /// Total price for this item (quantity * unit price)
  double get totalPrice => unitPrice * quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        nameAr,
        nameEn,
        imageUrl,
        basePrice,
        quantity,
        selectedVariations,
        specialInstructions,
      ];

  OrderItemEntity copyWith({
    String? id,
    String? productId,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    double? basePrice,
    int? quantity,
    List<SelectedVariation>? selectedVariations,
    String? specialInstructions,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  /// Create from product entity
  factory OrderItemEntity.fromProduct({
    required ProductEntity product,
    required int quantity,
    List<SelectedVariation> selectedVariations = const [],
    String? specialInstructions,
  }) {
    return OrderItemEntity(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      imageUrl: product.imageUrl,
      basePrice: product.effectivePrice,
      quantity: quantity,
      selectedVariations: selectedVariations,
      specialInstructions: specialInstructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'quantity': quantity,
      'selectedVariations': selectedVariations.map((v) => v.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['id'] as String,
      productId: json['productId'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedVariations: (json['selectedVariations'] as List<dynamic>?)
              ?.map((v) => SelectedVariation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'] as String?,
    );
  }
}

/// Order status history entry
class OrderStatusHistory extends Equatable {
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  const OrderStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [status, timestamp, note, updatedBy];

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'updatedBy': updatedBy,
    };
  }

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }
}

/// Delivery information for an order
class DeliveryInfo extends Equatable {
  final String addressLine;
  final String? buildingName;
  final String? floor;
  final String? apartment;
  final String? deliveryInstructions;
  final double latitude;
  final double longitude;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;

  const DeliveryInfo({
    required this.addressLine,
    this.buildingName,
    this.floor,
    this.apartment,
    this.deliveryInstructions,
    required this.latitude,
    required this.longitude,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
  });

  @override
  List<Object?> get props => [
        addressLine,
        buildingName,
        floor,
        apartment,
        deliveryInstructions,
        latitude,
        longitude,
        driverId,
        driverName,
        driverPhone,
        estimatedDeliveryTime,
        actualDeliveryTime,
      ];

  Map<String, dynamic> toJson() {
    return {
      'addressLine': addressLine,
      'buildingName': buildingName,
      'floor': floor,
      'apartment': apartment,
      'deliveryInstructions': deliveryInstructions,
      'latitude': latitude,
      'longitude': longitude,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
    };
  }

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      addressLine: json['addressLine'] as String,
      buildingName: json['buildingName'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'] as String)
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'] as String)
          : null,
    );
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final String userName;
  final String? userPhone;
  final String restaurantId;
  final String restaurantNameAr;
  final String restaurantNameEn;
  // final String branchId;
  // final String branchNameAr;
  // final String branchNameEn;
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final List<OrderStatusHistory> statusHistory;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? discountCode;
  final String? offerId;
  final DeliveryInfo? deliveryInfo;
  final String? paymentMethod;
  final bool isPaid;
  final DateTime? paidAt;
  final String? notes;
  final int estimatedPreparationMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Legacy fields for backward compatibility
  final String? sessionId;
  final bool isCancelled;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    this.userPhone,
    required this.restaurantId,
    required this.restaurantNameAr,
    required this.restaurantNameEn,
    // required this.branchId,
    // required this.branchNameAr,
    // required this.branchNameEn,
    required this.items,
    this.status = OrderStatus.pending,
    this.statusHistory = const [],
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.total,
    this.discountCode,
    this.offerId,
    this.deliveryInfo,
    this.paymentMethod,
    this.isPaid = false,
    this.paidAt,
    this.notes,
    this.estimatedPreparationMinutes = 30,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
    this.isCancelled = false,
  });

  /// Legacy getter for backward compatibility
  double get totalPrice => total;

  /// Get localized restaurant name
  String getLocalizedRestaurantName(String locale) {
    return locale == 'ar' ? restaurantNameAr : restaurantNameEn;
  }

  /// Get localized branch name
  // String getLocalizedBranchName(String locale) {
  //   return locale == 'ar' ? branchNameAr : branchNameEn;
  // }

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if user can modify this order (add/remove/update items)
  /// ONLY when status is pending
  bool get canModify => status.canModify;

  /// Alias for backward compatibility
  bool get canAddItems => canModify;

  /// Check if order can be cancelled
  /// ONLY when status is pending
  bool get canCancel => status.canCancel;

  /// Check if order is active (not arrived)
  bool get isActive => status.isActive;

  /// Check if order is in final state
  bool get isFinal => status.isFinal;

  /// Get estimated delivery time
  DateTime? get estimatedDeliveryTime {
    if (deliveryInfo?.estimatedDeliveryTime != null) {
      return deliveryInfo!.estimatedDeliveryTime;
    }
    // Calculate based on preparation time
    return createdAt.add(Duration(minutes: estimatedPreparationMinutes));
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        userName,
        userPhone,
        restaurantId,
        restaurantNameAr,
        restaurantNameEn,
        // branchId,
        // branchNameAr,
        // branchNameEn,
        items,
        status,
        statusHistory,
        subtotal,
        deliveryFee,
        discount,
        total,
        discountCode,
        offerId,
        deliveryInfo,
        paymentMethod,
        isPaid,
        paidAt,
        notes,
        estimatedPreparationMinutes,
        createdAt,
        updatedAt,
        sessionId,
        isCancelled,
      ];

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? userName,
    String? userPhone,
    String? restaurantId,
    String? restaurantNameAr,
    String? restaurantNameEn,
    String? branchId,
    String? branchNameAr,
    String? branchNameEn,
    List<OrderItemEntity>? items,
    OrderStatus? status,
    List<OrderStatusHistory>? statusHistory,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    String? discountCode,
    String? offerId,
    DeliveryInfo? deliveryInfo,
    String? paymentMethod,
    bool? isPaid,
    DateTime? paidAt,
    String? notes,
    int? estimatedPreparationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    bool? isCancelled,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantNameAr: restaurantNameAr ?? this.restaurantNameAr,
      restaurantNameEn: restaurantNameEn ?? this.restaurantNameEn,
      // branchId: branchId ?? this.branchId,
      // branchNameAr: branchNameAr ?? this.branchNameAr,
      // branchNameEn: branchNameEn ?? this.branchNameEn,
      items: items ?? this.items,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      discountCode: discountCode ?? this.discountCode,
      offerId: offerId ?? this.offerId,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      estimatedPreparationMinutes:
          estimatedPreparationMinutes ?? this.estimatedPreparationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
