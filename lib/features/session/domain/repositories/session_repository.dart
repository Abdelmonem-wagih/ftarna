import '../entities/session_entity.dart';

abstract class SessionRepository {
  Stream<SessionEntity?> get currentSessionStream;
  Future<SessionEntity?> getCurrentSession();
  Future<SessionEntity> createSession();
  Future<void> updateSession(SessionEntity session);
  Future<void> openSession(String sessionId);
  Future<void> closeSession(String sessionId);
  Future<void> markSessionDelivered(String sessionId);
  Future<void> setDeliveryFee(String sessionId, double fee);
  Future<void> setTotalBill(String sessionId, double bill);
  Stream<List<SessionEntity>> getSessionHistory();
}
