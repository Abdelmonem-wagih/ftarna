import '../entities/restaurant_entity.dart';

/// Restaurant repository interface
abstract class RestaurantRepository {
  /// Get all active restaurants
  Future<List<RestaurantEntity>> getRestaurants({
    int? limit,
    String? lastDocumentId,
  });

  /// Get restaurants by location (sorted by distance)
  Future<List<RestaurantEntity>> getRestaurantsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int? limit,
  });

  /// Get restaurant by ID
  Future<RestaurantEntity?> getRestaurantById(String id);

  /// Search restaurants
  Future<List<RestaurantEntity>> searchRestaurants(String query);

  /// Get restaurants by cuisine type
  Future<List<RestaurantEntity>> getRestaurantsByCuisine(String cuisineType);

  /// Get featured/popular restaurants
  Future<List<RestaurantEntity>> getFeaturedRestaurants({int? limit});

  /// Create a new restaurant
  Future<RestaurantEntity> createRestaurant(RestaurantEntity restaurant);

  /// Update restaurant
  Future<void> updateRestaurant(RestaurantEntity restaurant);

  /// Delete restaurant
  Future<void> deleteRestaurant(String id);

  /// Stream restaurants (real-time updates)
  Stream<List<RestaurantEntity>> streamRestaurants();

  /// Stream single restaurant
  Stream<RestaurantEntity?> streamRestaurant(String id);

  /// Get restaurants owned by user
  Future<List<RestaurantEntity>> getRestaurantsByOwner(String ownerId);

  /// Update restaurant rating (called after review)
  Future<void> updateRating(String restaurantId, double newRating, int totalReviews);
}
