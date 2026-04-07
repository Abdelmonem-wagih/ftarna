import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel {
  static OrderItemEntity fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['id'] as String? ?? json['itemId'] as String? ?? '',
      productId: json['productId'] as String? ?? json['itemId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ??
                 (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      selectedVariations: (json['selectedVariations'] as List<dynamic>?)
              ?.map((v) => SelectedVariation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  static Map<String, dynamic> toJson(OrderItemEntity item) {
    return {
      'id': item.id,
      'productId': item.productId,
      'nameAr': item.nameAr,
      'nameEn': item.nameEn,
      'imageUrl': item.imageUrl,
      'basePrice': item.basePrice,
      'quantity': item.quantity,
      'selectedVariations': item.selectedVariations.map((v) => v.toJson()).toList(),
      'specialInstructions': item.specialInstructions,
      // Legacy fields for backward compatibility
      'itemId': item.productId,
      'name': item.nameEn,
      'price': item.unitPrice,
    };
  }
}

class OrderModel {
  static OrderEntity fromJson(Map<String, dynamic> json, String id) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    final items = itemsList
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final statusHistoryList = (json['statusHistory'] as List<dynamic>?) ?? [];
    final statusHistory = statusHistoryList
        .map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse status
    OrderStatus status;
    final statusStr = json['status'] as String?;
    if (statusStr != null) {
      status = OrderStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => OrderStatus.pending,
      );
    } else {
      // Legacy: determine status from old fields
      if (json['isCancelled'] == true) {
        status = OrderStatus.cancelled;
      } else if (json['isPaid'] == true) {
        status = OrderStatus.arrived;
      } else {
        status = OrderStatus.pending;
      }
    }

    // Parse delivery info
    DeliveryInfo? deliveryInfo;
    final deliveryData = json['deliveryInfo'] as Map<String, dynamic>?;
    if (deliveryData != null) {
      deliveryInfo = DeliveryInfo.fromJson(deliveryData);
    }

    // Calculate totals
    final subtotal = (json['subtotal'] as num?)?.toDouble() ??
                     (json['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final deliveryFee = (json['deliveryFee'] as num?)?.toDouble() ?? 0.0;
    final discount = (json['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total'] as num?)?.toDouble() ?? subtotal;

    return OrderEntity(
      id: id,
      orderNumber: json['orderNumber'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String?,
      restaurantId: json['restaurantId'] as String? ?? '',
      restaurantNameAr: json['restaurantNameAr'] as String? ?? '',
      restaurantNameEn: json['restaurantNameEn'] as String? ?? '',
      // branchId: json['branchId'] as String? ?? '',
      // branchNameAr: json['branchNameAr'] as String? ?? '',
      // branchNameEn: json['branchNameEn'] as String? ?? '',
      items: items,
      status: status,
      statusHistory: statusHistory,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      discountCode: json['discountCode'] as String?,
      offerId: json['offerId'] as String?,
      deliveryInfo: deliveryInfo,
      paymentMethod: json['paymentMethod'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      paidAt: json['paidAt'] != null
          ? (json['paidAt'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
      estimatedPreparationMinutes: json['estimatedPreparationMinutes'] as int? ?? 30,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      // Legacy fields
      sessionId: json['sessionId'] as String?,
      isCancelled: json['isCancelled'] as bool? ?? false,
    );
  }

  static OrderEntity fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return fromJson(data, doc.id);
  }

  static Map<String, dynamic> toJson(OrderEntity entity) {
    return {
      'orderNumber': entity.orderNumber,
      'userId': entity.userId,
      'userName': entity.userName,
      'userPhone': entity.userPhone,
      'restaurantId': entity.restaurantId,
      'restaurantNameAr': entity.restaurantNameAr,
      'restaurantNameEn': entity.restaurantNameEn,
      // 'branchId': entity.branchId,
      // 'branchNameAr': entity.branchNameAr,
      // 'branchNameEn': entity.branchNameEn,
      'items': entity.items.map((e) => OrderItemModel.toJson(e)).toList(),
      'status': entity.status.name,
      'statusHistory': entity.statusHistory.map((h) => h.toJson()).toList(),
      'subtotal': entity.subtotal,
      'deliveryFee': entity.deliveryFee,
      'discount': entity.discount,
      'total': entity.total,
      'discountCode': entity.discountCode,
      'offerId': entity.offerId,
      'deliveryInfo': entity.deliveryInfo?.toJson(),
      'paymentMethod': entity.paymentMethod,
      'isPaid': entity.isPaid,
      'paidAt': entity.paidAt != null ? Timestamp.fromDate(entity.paidAt!) : null,
      'notes': entity.notes,
      'estimatedPreparationMinutes': entity.estimatedPreparationMinutes,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': entity.updatedAt != null
          ? Timestamp.fromDate(entity.updatedAt!)
          : null,
      // Legacy fields
      'sessionId': entity.sessionId,
      'isCancelled': entity.isCancelled,
      'totalPrice': entity.total, // Backward compatibility
    };
  }

  static OrderEntity fromEntity(OrderEntity entity) => entity;
}

// Backward compatible wrapper
extension OrderModelExtension on OrderEntity {
  OrderEntity toEntity() => this;
}
