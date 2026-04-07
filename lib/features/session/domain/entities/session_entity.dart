import 'package:equatable/equatable.dart';

enum SessionStatus { open, closed, delivered }

class SessionEntity extends Equatable {
  final String id;
  final bool isOpen;
  final DateTime createdAt;
  final double deliveryFee;
  final double totalBill;
  final SessionStatus status;

  const SessionEntity({
    required this.id,
    required this.isOpen,
    required this.createdAt,
    this.deliveryFee = 0,
    this.totalBill = 0,
    this.status = SessionStatus.open,
  });

  @override
  List<Object?> get props => [id, isOpen, createdAt, deliveryFee, totalBill, status];

  SessionEntity copyWith({
    String? id,
    bool? isOpen,
    DateTime? createdAt,
    double? deliveryFee,
    double? totalBill,
    SessionStatus? status,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalBill: totalBill ?? this.totalBill,
      status: status ?? this.status,
    );
  }

  bool get canOrder => status == SessionStatus.open && isOpen;
}
