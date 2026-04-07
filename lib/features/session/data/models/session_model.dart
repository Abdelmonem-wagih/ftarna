import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.isOpen,
    required super.createdAt,
    super.deliveryFee,
    super.totalBill,
    super.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      isOpen: json['isOpen'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      totalBill: (json['totalBill'] as num?)?.toDouble() ?? 0,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'open'),
        orElse: () => SessionStatus.open,
      ),
    );
  }

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'isOpen': isOpen,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryFee': deliveryFee,
      'totalBill': totalBill,
      'status': status.name,
    };
  }

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      isOpen: entity.isOpen,
      createdAt: entity.createdAt,
      deliveryFee: entity.deliveryFee,
      totalBill: entity.totalBill,
      status: entity.status,
    );
  }

  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      isOpen: isOpen,
      createdAt: createdAt,
      deliveryFee: deliveryFee,
      totalBill: totalBill,
      status: status,
    );
  }
}
