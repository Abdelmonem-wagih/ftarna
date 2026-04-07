import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import '../../../../core/utils/constants.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../models/restaurant_model.dart';

/// Restaurant repository implementation using Firestore
class RestaurantRepositoryImpl implements RestaurantRepository {
  final FirebaseFirestore _firestore;

  RestaurantRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.restaurants);

  @override
  Future<List<RestaurantEntity>> getRestaurants({
    int? limit,
    String? lastDocumentId,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (lastDocumentId != null) {
      final lastDoc = await _collection.doc(lastDocumentId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<RestaurantEntity>> getRestaurantsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int? limit,
  }) async {
    // Calculate bounding box for initial filtering
    final latDelta = radiusKm / 111.0; // ~111km per degree latitude
    final lngDelta = radiusKm / (111.0 * math.cos(latitude * math.pi / 180));

    final minLat = latitude - latDelta;
    final maxLat = latitude + latDelta;
    final minLng = longitude - lngDelta;
    final maxLng = longitude + lngDelta;

    // Query using GeoPoint bounds
    final snapshot = await _collection
        .where('isActive', isEqualTo: true)
        .get();

    // Filter by actual distance and sort
    final restaurants = snapshot.docs
        .map((doc) => RestaurantModel.fromFirestore(doc))
        .where((r) {
          return r.latitude >= minLat &&
              r.latitude <= maxLat &&
              r.longitude >= minLng &&
              r.longitude <= maxLng;
        })
        .map((r) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            r.latitude,
            r.longitude,
          );
          return _RestaurantWithDistance(r, distance);
        })
        .where((r) => r.distance <= radiusKm)
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));

    final result = restaurants.map((r) => r.restaurant).toList();

    if (limit != null && result.length > limit) {
      return result.take(limit).toList();
    }

    return result;
  }

  @override
  Future<RestaurantEntity?> getRestaurantById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return RestaurantModel.fromFirestore(doc);
  }

  @override
  Future<List<RestaurantEntity>> searchRestaurants(String query) async {
    final lowerQuery = query.toLowerCase();

    // Search in multiple fields
    final snapshot = await _collection
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => RestaurantModel.fromFirestore(doc))
        .where((r) {
          return r.nameEn.toLowerCase().contains(lowerQuery) ||
              r.nameAr.contains(query) ||
              (r.descriptionEn?.toLowerCase().contains(lowerQuery) ?? false) ||
              (r.descriptionAr?.contains(query) ?? false) ||
              r.cuisineTypes.any((c) => c.toLowerCase().contains(lowerQuery));
        })
        .toList();
  }

  @override
  Future<List<RestaurantEntity>> getRestaurantsByCuisine(String cuisineType) async {
    final snapshot = await _collection
        .where('isActive', isEqualTo: true)
        .where('cuisineTypes', arrayContains: cuisineType)
        .get();

    return snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<RestaurantEntity>> getFeaturedRestaurants({int? limit}) async {
    Query<Map<String, dynamic>> query = _collection
        .where('isActive', isEqualTo: true)
        .where('isVerified', isEqualTo: true)
        .orderBy('rating', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();
  }

  @override
  Future<RestaurantEntity> createRestaurant(RestaurantEntity restaurant) async {
    final model = RestaurantModel.fromEntity(restaurant);
    final docRef = await _collection.add(model.toFirestore());
    return model.copyWith(id: docRef.id) as RestaurantModel;
  }

  @override
  Future<void> updateRestaurant(RestaurantEntity restaurant) async {
    final model = RestaurantModel.fromEntity(restaurant);
    await _collection.doc(restaurant.id).update({
      ...model.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteRestaurant(String id) async {
    // Soft delete
    await _collection.doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<RestaurantEntity>> streamRestaurants() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<RestaurantEntity?> streamRestaurant(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RestaurantModel.fromFirestore(doc);
    });
  }

  @override
  Future<List<RestaurantEntity>> getRestaurantsByOwner(String ownerId) async {
    final snapshot = await _collection
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map((doc) => RestaurantModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateRating(
    String restaurantId,
    double newRating,
    int totalReviews,
  ) async {
    await _collection.doc(restaurantId).update({
      'rating': newRating,
      'totalReviews': totalReviews,
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
class _RestaurantWithDistance {
  final RestaurantEntity restaurant;
  final double distance;

  _RestaurantWithDistance(this.restaurant, this.distance);
}
