import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseFirestore _firestore;

  SessionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _sessionsCollection =>
      _firestore.collection(FirestoreCollections.sessions);

  @override
  Stream<SessionEntity?> get currentSessionStream {
    return _sessionsCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return SessionModel.fromFirestore(snapshot.docs.first).toEntity();
    });
  }

  @override
  Future<SessionEntity?> getCurrentSession() async {
    final snapshot = await _sessionsCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return SessionModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<SessionEntity> createSession() async {
    final session = SessionModel(
      id: '',
      isOpen: true,
      createdAt: DateTime.now(),
      deliveryFee: 0,
      totalBill: 0,
      status: SessionStatus.open,
    );

    final docRef = await _sessionsCollection.add(session.toJson());
    return SessionModel(
      id: docRef.id,
      isOpen: session.isOpen,
      createdAt: session.createdAt,
      deliveryFee: session.deliveryFee,
      totalBill: session.totalBill,
      status: session.status,
    );
  }

  @override
  Future<void> updateSession(SessionEntity session) async {
    final model = SessionModel.fromEntity(session);
    await _sessionsCollection.doc(session.id).update(model.toJson());
  }

  @override
  Future<void> openSession(String sessionId) async {
    await _sessionsCollection.doc(sessionId).update({
      'isOpen': true,
      'status': SessionStatus.open.name,
    });
  }

  @override
  Future<void> closeSession(String sessionId) async {
    await _sessionsCollection.doc(sessionId).update({
      'isOpen': false,
      'status': SessionStatus.closed.name,
    });
  }

  @override
  Future<void> markSessionDelivered(String sessionId) async {
    await _sessionsCollection.doc(sessionId).update({
      'isOpen': false,
      'status': SessionStatus.delivered.name,
    });
  }

  @override
  Future<void> setDeliveryFee(String sessionId, double fee) async {
    await _sessionsCollection.doc(sessionId).update({
      'deliveryFee': fee,
    });
  }

  @override
  Future<void> setTotalBill(String sessionId, double bill) async {
    await _sessionsCollection.doc(sessionId).update({
      'totalBill': bill,
    });
  }

  @override
  Stream<List<SessionEntity>> getSessionHistory() {
    return _sessionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }
}
