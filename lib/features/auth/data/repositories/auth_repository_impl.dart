import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getUserById(user.uid);
    });
  }

  @override
  Future<UserEntity?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUserById(user.uid);
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = await getUserById(credential.user!.uid);
    if (user == null) {
      throw Exception('User not found');
    }
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userModel = UserModel(
      id: credential.user!.uid,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    await _usersCollection.doc(userModel.id).set(userModel.toJson());
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _usersCollection.doc(user.id).update(model.toJson());
  }

  @override
  Stream<List<UserEntity>> getAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }
}
