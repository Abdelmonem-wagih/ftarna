part of 'restaurant_cubit.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantSearching extends RestaurantState {}

class RestaurantDetailsLoading extends RestaurantState {}

class RestaurantsLoaded extends RestaurantState {
  final List<RestaurantEntity> restaurants;
  final double? userLatitude;
  final double? userLongitude;
  final String? filterCuisine;
  final bool hasReachedMax;

  const RestaurantsLoaded(
    this.restaurants, {
    this.userLatitude,
    this.userLongitude,
    this.filterCuisine,
    this.hasReachedMax = false,
  });

  RestaurantsLoaded copyWith({
    List<RestaurantEntity>? restaurants,
    double? userLatitude,
    double? userLongitude,
    String? filterCuisine,
    bool? hasReachedMax,
  }) {
    return RestaurantsLoaded(
      restaurants ?? this.restaurants,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      filterCuisine: filterCuisine ?? this.filterCuisine,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        restaurants,
        userLatitude,
        userLongitude,
        filterCuisine,
        hasReachedMax,
      ];
}

class FeaturedRestaurantsLoaded extends RestaurantState {
  final List<RestaurantEntity> restaurants;

  const FeaturedRestaurantsLoaded(this.restaurants);

  @override
  List<Object?> get props => [restaurants];
}

class RestaurantSearchResults extends RestaurantState {
  final List<RestaurantEntity> restaurants;
  final String query;

  const RestaurantSearchResults(this.restaurants, this.query);

  @override
  List<Object?> get props => [restaurants, query];
}

class RestaurantDetailsLoaded extends RestaurantState {
  final RestaurantEntity restaurant;

  const RestaurantDetailsLoaded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError(this.message);

  @override
  List<Object?> get props => [message];
}
