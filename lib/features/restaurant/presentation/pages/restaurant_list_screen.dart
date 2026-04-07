import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubit/restaurant_cubit.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/restaurant_search_bar.dart';
import 'restaurant_details_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNearbyOnly = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _scrollController.addListener(_onScroll);
  }

  void _loadRestaurants() {
    if (_showNearbyOnly) {
      context.read<RestaurantCubit>().loadRestaurantsByLocation();
    } else {
      context.read<RestaurantCubit>().loadRestaurants();
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RestaurantCubit>().loadMoreRestaurants();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Toggle nearby/all
          IconButton(
            icon: Icon(_showNearbyOnly ? Icons.near_me : Icons.public),
            tooltip: _showNearbyOnly ? 'Show All' : 'Show Nearby',
            onPressed: () {
              setState(() {
                _showNearbyOnly = !_showNearbyOnly;
              });
              _loadRestaurants();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          RestaurantSearchBar(
            onSearch: (query) {
              context.read<RestaurantCubit>().searchRestaurants(query);
            },
          ),
          // Filter chips
          _buildFilterChips(context, locale),
          // Restaurant List
          Expanded(
            child: BlocBuilder<RestaurantCubit, RestaurantState>(
              builder: (context, state) {
                if (state is RestaurantLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RestaurantError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRestaurants,
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  );
                }

                if (state is RestaurantsLoaded) {
                  return _buildRestaurantList(
                    context,
                    state.restaurants,
                    locale,
                    state.userLatitude,
                    state.userLongitude,
                  );
                }

                if (state is RestaurantSearchResults) {
                  if (state.restaurants.isEmpty) {
                    return Center(
                      child: Text('No results for "${state.query}"'),
                    );
                  }
                  return _buildRestaurantList(
                    context,
                    state.restaurants,
                    locale,
                    null,
                    null,
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, String locale) {
    final cuisineTypes = [
      'Fast Food',
      'Pizza',
      'Seafood',
      'Arabic',
      'Asian',
      'Italian',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cuisineTypes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cuisineTypes[index]),
              selected: false,
              onSelected: (selected) {
                if (selected) {
                  context
                      .read<RestaurantCubit>()
                      .loadRestaurantsByCuisine(cuisineTypes[index]);
                } else {
                  _loadRestaurants();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantList(
    BuildContext context,
    List<RestaurantEntity> restaurants,
    String locale,
    double? userLat,
    double? userLng,
  ) {
    if (restaurants.isEmpty) {
      return const Center(
        child: Text('No restaurants found'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadRestaurants();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          // Calculate distance if user location is available
          double? distance;
          if (userLat != null && userLng != null) {
            final locationService = context.read<LocationService>();
            distance = locationService.calculateDistance(
              userLat,
              userLng,
              restaurant.latitude,
              restaurant.longitude,
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(
              restaurant: restaurant,
              locale: locale,
              distance: distance,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailsScreen(
                      restaurantId: restaurant.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
