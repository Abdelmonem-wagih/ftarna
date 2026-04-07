import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubit/restaurant_cubit.dart';
import 'modern_restaurant_details_screen.dart';

class ModernRestaurantListScreen extends StatefulWidget {
  const ModernRestaurantListScreen({super.key});

  @override
  State<ModernRestaurantListScreen> createState() =>
      _ModernRestaurantListScreenState();
}

class _ModernRestaurantListScreenState
    extends State<ModernRestaurantListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCuisine;
  bool _showNearbyOnly = true;

  final List<String> _cuisineTypes = [
    'All',
    'Fast Food',
    'Pizza',
    'Seafood',
    'Arabic',
    'Asian',
    'Italian',
    'Desserts',
  ];

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, l10n),
            // Search Bar
            _buildSearchBar(context),
            // Cuisine filters
            _buildCuisineFilters(),
            // Restaurant list
            Expanded(
              child: BlocBuilder<RestaurantCubit, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading) {
                    return _buildLoadingState();
                  }

                  if (state is RestaurantError) {
                    return AppErrorState.general(
                      description: state.message,
                      onRetry: _loadRestaurants,
                    );
                  }

                  if (state is RestaurantsLoaded) {
                    if (state.restaurants.isEmpty) {
                      return AppEmptyState.noRestaurants(
                        onAction: _loadRestaurants,
                      );
                    }
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
                      return AppEmptyState.noResults(
                        description: 'No results for "${state.query}"',
                        onAction: () {
                          _searchController.clear();
                          _loadRestaurants();
                        },
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.goodMorning,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What would you like to eat?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: _showNearbyOnly ? Icons.near_me : Icons.public,
            onPressed: () {
              setState(() {
                _showNearbyOnly = !_showNearbyOnly;
              });
              _loadRestaurants();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) {
            if (query.isEmpty) {
              _loadRestaurants();
            }
          },
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              context.read<RestaurantCubit>().searchRestaurants(query);
            }
          },
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            prefixIcon: Icon(
              Icons.search,
              color: AppTheme.textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _loadRestaurants();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuisineFilters() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cuisineTypes.length,
        itemBuilder: (context, index) {
          final cuisine = _cuisineTypes[index];
          final isSelected =
              (_selectedCuisine == null && cuisine == 'All') ||
                  _selectedCuisine == cuisine;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TagChip(
              label: cuisine,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCuisine = cuisine == 'All' ? null : cuisine;
                });
                if (_selectedCuisine != null) {
                  context
                      .read<RestaurantCubit>()
                      .loadRestaurantsByCuisine(_selectedCuisine!);
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

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: RestaurantCardShimmer(),
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
    return RefreshIndicator(
      onRefresh: () async {
        _loadRestaurants();
      },
      color: AppTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          double? distance;

          if (userLat != null && userLng != null) {
            distance = _calculateDistance(
              userLat,
              userLng,
              restaurant.latitude,
              restaurant.longitude,
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ModernRestaurantCard(
              restaurant: restaurant,
              locale: locale,
              distance: distance,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModernRestaurantDetailsScreen(
                      restaurant: restaurant,
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

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Simple distance calculation (Haversine formula simplified)
    final latDiff = (lat2 - lat1).abs();
    final lngDiff = (lng2 - lng1).abs();
    return (latDiff + lngDiff) * 111; // Approximate km
  }
}

/// Modern restaurant card widget
class ModernRestaurantCard extends StatelessWidget {
  final RestaurantEntity restaurant;
  final String locale;
  final double? distance;
  final VoidCallback? onTap;

  const ModernRestaurantCard({
    super.key,
    required this.restaurant,
    required this.locale,
    this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AppCachedImage(
                    imageUrl: restaurant.coverImageUrl ?? restaurant.logoUrl,
                    height: 150,
                    width: double.infinity,
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: RatingBadge(rating: restaurant.rating),
                ),
                // Discount badge if applicable
                if (restaurant.deliveryFee == 0)
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: FreeDeliveryBadge(),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo
                  RestaurantLogo(
                    imageUrl: restaurant.logoUrl,
                    size: 56,
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.getLocalizedName(locale),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (restaurant.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.cuisineTypes.take(3).join(' • '),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (distance != null) ...[
                              InfoBadge.distance(distance!),
                              const SizedBox(width: 16),
                            ],
                            if (restaurant.estimatedDeliveryMinutes != null)
                              InfoBadge.deliveryTime(
                                restaurant.estimatedDeliveryMinutes!,
                              ),
                            if (restaurant.minimumOrderAmount != null) ...[
                              const SizedBox(width: 16),
                              InfoBadge.minimumOrder(
                                restaurant.minimumOrderAmount!,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
