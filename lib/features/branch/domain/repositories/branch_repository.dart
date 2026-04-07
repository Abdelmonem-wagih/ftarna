import '../entities/branch_entity.dart';

/// Branch repository interface
abstract class BranchRepository {
  /// Get all branches for a restaurant
  Future<List<BranchEntity>> getBranchesByRestaurant(String restaurantId);

  /// Get branches by location (sorted by distance)
  Future<List<BranchEntity>> getBranchesByLocation({
    required String restaurantId,
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  });

  /// Get nearest branch for a restaurant
  Future<BranchEntity?> getNearestBranch({
    required String restaurantId,
    required double latitude,
    required double longitude,
  });

  /// Get branch by ID
  Future<BranchEntity?> getBranchById(String id);

  /// Get branches by admin
  Future<List<BranchEntity>> getBranchesByAdmin(String adminId);

  /// Create a new branch
  Future<BranchEntity> createBranch(BranchEntity branch);

  /// Update branch
  Future<void> updateBranch(BranchEntity branch);

  /// Delete branch
  Future<void> deleteBranch(String id);

  /// Toggle branch open/close status
  Future<void> toggleBranchOpen(String branchId, bool isOpen);

  /// Stream branches for a restaurant (real-time)
  Stream<List<BranchEntity>> streamBranches(String restaurantId);

  /// Stream single branch
  Stream<BranchEntity?> streamBranch(String id);

  /// Add admin to branch
  Future<void> addAdminToBranch(String branchId, String adminId);

  /// Remove admin from branch
  Future<void> removeAdminFromBranch(String branchId, String adminId);

  /// Update branch rating
  Future<void> updateRating(String branchId, double newRating, int totalReviews);

  /// Increment order count
  Future<void> incrementOrderCount(String branchId);
}
