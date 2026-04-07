import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> get currentUser;
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<UserEntity?> getUserById(String userId);
  Future<void> updateUser(UserEntity user);
  Stream<List<UserEntity>> getAllUsers();
}
