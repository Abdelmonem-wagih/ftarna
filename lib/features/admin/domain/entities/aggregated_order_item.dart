import 'package:equatable/equatable.dart';

/// Represents an aggregated menu item across all orders
class AggregatedOrderItem extends Equatable {
  final String productId;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final int totalQuantity;
  final double unitPrice;
  final double totalPrice;

  const AggregatedOrderItem({
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.totalQuantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  String getLocalizedName(String locale) {
    return locale == 'ar' ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [
        productId,
        nameAr,
        nameEn,
        imageUrl,
        totalQuantity,
        unitPrice,
        totalPrice,
      ];
}
