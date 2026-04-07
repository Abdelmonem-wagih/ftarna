import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import '../../../../core/utils/constants.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/branch_repository.dart';
import '../models/branch_model.dart';

/// Branch repository implementation using Firestore
class BranchRepositoryImpl implements BranchRepository {
  final FirebaseFirestore _firestore;

  BranchRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.branches);

  @override
  Future<List<BranchEntity>> getBranchesByRestaurant(String restaurantId) async {
    final snapshot = await _collection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => BranchModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<BranchEntity>> getBranchesByLocation({
    required String restaurantId,
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    final branches = await getBranchesByRestaurant(restaurantId);

    final branchesWithDistance = branches
        .map((b) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            b.latitude,
            b.longitude,
          );
          return _BranchWithDistance(b, distance);
        })
        .where((b) => b.distance <= radiusKm)
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));

    return branchesWithDistance.map((b) => b.branch).toList();
  }

  @override
  Future<BranchEntity?> getNearestBranch({
    required String restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    final branches = await getBranchesByLocation(
      restaurantId: restaurantId,
      latitude: latitude,
      longitude: longitude,
      radiusKm: 50.0, // Search in a wider radius
    );

    if (branches.isEmpty) {
      // If no branches in radius, get all and find nearest
      final allBranches = await getBranchesByRestaurant(restaurantId);
      if (allBranches.isEmpty) return null;

      allBranches.sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      return allBranches.first;
    }

    return branches.first;
  }

  @override
  Future<BranchEntity?> getBranchById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return BranchModel.fromFirestore(doc);
  }

  @override
  Future<List<BranchEntity>> getBranchesByAdmin(String adminId) async {
    final snapshot = await _collection
        .where('adminIds', arrayContains: adminId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => BranchModel.fromFirestore(doc)).toList();
  }

  @override
  Future<BranchEntity> createBranch(BranchEntity branch) async {
    final model = BranchModel.fromEntity(branch);
    final docRef = await _collection.add(model.toFirestore());
    return model.copyWith(id: docRef.id) as BranchModel;
  }

  @override
  Future<void> updateBranch(BranchEntity branch) async {
    final model = BranchModel.fromEntity(branch);
    await _collection.doc(branch.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteBranch(String id) async {
    // Soft delete
    await _collection.doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleBranchOpen(String branchId, bool isOpen) async {
    await _collection.doc(branchId).update({
      'isOpen': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<BranchEntity>> streamBranches(String restaurantId) {
    return _collection
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BranchModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<BranchEntity?> streamBranch(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BranchModel.fromFirestore(doc);
    });
  }

  @override
  Future<void> addAdminToBranch(String branchId, String adminId) async {
    await _collection.doc(branchId).update({
      'adminIds': FieldValue.arrayUnion([adminId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeAdminFromBranch(String branchId, String adminId) async {
    await _collection.doc(branchId).update({
      'adminIds': FieldValue.arrayRemove([adminId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateRating(
    String branchId,
    double newRating,
    int totalReviews,
  ) async {
    await _collection.doc(branchId).update({
      'rating': newRating,
      'totalReviews': totalReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementOrderCount(String branchId) async {
    await _collection.doc(branchId).update({
      'totalOrders': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180;
}

/// Helper class for sorting by distance
class _BranchWithDistance {
  final BranchEntity branch;
  final double distance;

  _BranchWithDistance(this.branch, this.distance);
}
