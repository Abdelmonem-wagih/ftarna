import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final RestaurantRepository _restaurantRepository;
  final LocationService _locationService;
  StreamSubscription? _restaurantsSubscription;

  RestaurantCubit(this._restaurantRepository, this._locationService)
      : super(RestaurantInitial());

  /// Load restaurants
  Future<void> loadRestaurants() async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _restaurantRepository.getRestaurants();
      emit(RestaurantsLoaded(restaurants));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Load restaurants sorted by distance
  Future<void> loadRestaurantsByLocation() async {
    emit(RestaurantLoading());
    try {
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        // Fallback to unsorted list
        final restaurants = await _restaurantRepository.getRestaurants();
        emit(RestaurantsLoaded(restaurants));
        return;
      }

      final restaurants = await _restaurantRepository.getRestaurantsByLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      emit(RestaurantsLoaded(
        restaurants,
        userLatitude: location.latitude,
        userLongitude: location.longitude,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Load featured restaurants
  Future<void> loadFeaturedRestaurants({int? limit}) async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _restaurantRepository.getFeaturedRestaurants(
        limit: limit,
      );
      emit(FeaturedRestaurantsLoaded(restaurants));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Search restaurants
  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      await loadRestaurants();
      return;
    }

    emit(RestaurantSearching());
    try {
      final restaurants = await _restaurantRepository.searchRestaurants(query);
      emit(RestaurantSearchResults(restaurants, query));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Load restaurants by cuisine
  Future<void> loadRestaurantsByCuisine(String cuisineType) async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _restaurantRepository.getRestaurantsByCuisine(
        cuisineType,
      );
      emit(RestaurantsLoaded(restaurants, filterCuisine: cuisineType));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Get restaurant details
  Future<void> getRestaurantDetails(String restaurantId) async {
    emit(RestaurantDetailsLoading());
    try {
      final restaurant = await _restaurantRepository.getRestaurantById(
        restaurantId,
      );
      if (restaurant != null) {
        emit(RestaurantDetailsLoaded(restaurant));
      } else {
        emit(const RestaurantError('Restaurant not found'));
      }
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  /// Stream restaurants (real-time updates)
  void streamRestaurants() {
    emit(RestaurantLoading());
    _restaurantsSubscription?.cancel();
    _restaurantsSubscription = _restaurantRepository.streamRestaurants().listen(
      (restaurants) {
        emit(RestaurantsLoaded(restaurants));
      },
      onError: (error) {
        emit(RestaurantError(error.toString()));
      },
    );
  }

  /// Load more restaurants (pagination)
  Future<void> loadMoreRestaurants() async {
    if (state is! RestaurantsLoaded) return;

    final currentState = state as RestaurantsLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final lastRestaurant = currentState.restaurants.lastOrNull;
      if (lastRestaurant == null) return;

      final moreRestaurants = await _restaurantRepository.getRestaurants(
        limit: 20,
        lastDocumentId: lastRestaurant.id,
      );

      if (moreRestaurants.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          restaurants: [...currentState.restaurants, ...moreRestaurants],
        ));
      }
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _restaurantsSubscription?.cancel();
    return super.close();
  }
}
