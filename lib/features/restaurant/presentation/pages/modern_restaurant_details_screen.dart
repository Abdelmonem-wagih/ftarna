import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../branch/domain/repositories/branch_repository.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/entities/restaurant_entity.dart';

class ModernRestaurantDetailsScreen extends StatefulWidget {
  final RestaurantEntity restaurant;

  const ModernRestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<ModernRestaurantDetailsScreen> createState() =>
      _ModernRestaurantDetailsScreenState();
}

class _ModernRestaurantDetailsScreenState
    extends State<ModernRestaurantDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<BranchEntity> _branches = [];
  BranchEntity? _selectedBranch;
  List<CategoryEntity> _categories = [];
  Map<String, List<ProductEntity>> _productsByCategory = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load branches
      final branchRepo = sl<BranchRepository>();
      _branches = await branchRepo.getBranchesByRestaurant(widget.restaurant.id);

      // Auto-select nearest or first branch
      if (_branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }

      // Load categories
      final categoryRepo = sl<CategoryRepository>();
      _categories = await categoryRepo.getCategoriesByRestaurant(
        widget.restaurant.id,
      );

      // Initialize tab controller
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
      );

      // Load products for each category
      final productRepo = sl<ProductRepository>();
      for (final category in _categories) {
        final products = await productRepo.getProductsByCategory(
          category.id,
        );
        _productsByCategory[category.id] = products;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const PageLoading(message: 'Loading menu...')
          : _error != null
              ? AppErrorState.general(
                  description: _error,
                  onRetry: _loadData,
                )
              : _buildContent(context, locale, l10n),
      floatingActionButton: _buildCartFAB(context),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String locale,
    AppLocalizations l10n,
  ) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // App bar with cover image
        _buildSliverAppBar(context, locale),
        // Restaurant info
        SliverToBoxAdapter(
          child: _buildRestaurantInfo(locale),
        ),
        // Branch selector
        if (_branches.length > 1)
          SliverToBoxAdapter(
            child: _buildBranchSelector(locale),
          ),
        // Category tabs
        if (_categories.isNotEmpty)
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabBarDelegate(
              tabController: _tabController,
              categories: _categories,
              locale: locale,
            ),
          ),
      ],
      body: _categories.isEmpty
          ? const AppEmptyState.noItems(
              title: 'No menu items',
              description: 'This restaurant hasn\'t added any items yet',
            )
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final products = _productsByCategory[category.id] ?? [];
                return _buildProductGrid(products, locale);
              }).toList(),
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String locale) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // TODO: Add to favorites
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Share restaurant
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CoverImage(
          imageUrl:
              widget.restaurant.coverImageUrl ?? widget.restaurant.logoUrl,
          height: 220,
          child: Positioned(
            bottom: 16,
            right: 16,
            child: RatingBadge(rating: widget.restaurant.rating, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(String locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RestaurantLogo(
                imageUrl: widget.restaurant.logoUrl,
                size: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurant.getLocalizedName(locale),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.restaurant.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.restaurant.cuisineTypes.join(' • '),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBar(
                          rating: widget.restaurant.rating,
                          totalReviews: widget.restaurant.totalReviews,
                        ),
                        const SizedBox(width: 16),
                        StatusBadge.openClosed(
                          isOpen: widget.restaurant.isActive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.restaurant.getLocalizedDescription(locale) != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.restaurant.getLocalizedDescription(locale)!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Info row
          Row(
            children: [
              if (widget.restaurant.estimatedDeliveryMinutes != null)
                _buildInfoChip(
                  Icons.access_time,
                  '${widget.restaurant.estimatedDeliveryMinutes} min',
                ),
              if (widget.restaurant.deliveryFee != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.delivery_dining,
                  widget.restaurant.deliveryFee == 0
                      ? 'Free Delivery'
                      : '${widget.restaurant.deliveryFee?.toInt()} EGP',
                ),
              ],
              if (widget.restaurant.minimumOrderAmount != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.shopping_bag_outlined,
                  'Min ${widget.restaurant.minimumOrderAmount?.toInt()} EGP',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector(String locale) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Branch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _branches.length,
              itemBuilder: (context, index) {
                final branch = _branches[index];
                final isSelected = _selectedBranch?.id == branch.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBranch = branch;
                    });
                  },
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          branch.getLocalizedName(locale),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                branch.getLocalizedAddress(locale),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductEntity> products, String locale) {
    if (products.isEmpty) {
      return const Center(
        child: InlineEmptyState(
          message: 'No products in this category',
          icon: Icons.fastfood_outlined,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            CartItemEntity? cartItem;
            if (cartState is CartLoaded) {
              // Find if this product is in the cart
              cartItem = cartState.cart.items.cast<CartItemEntity?>().firstWhere(
                (item) => item?.productId == product.id,
                orElse: () => null,
              );
            }

            return ModernProductCard(
              product: product,
              locale: locale,
              branchId: _selectedBranch?.id,
              cartItem: cartItem,
              onAddToCart: () => _handleAddToCart(product),
              onIncrease: cartItem != null
                  ? () => _handleIncreaseQuantity(cartItem!.id, cartItem.quantity)
                  : null,
              onDecrease: cartItem != null
                  ? () => _handleDecreaseQuantity(cartItem!.id, cartItem.quantity)
                  : null,
            );
          },
        );
      },
    );
  }

  void _handleAddToCart(ProductEntity product) {
    final cartCubit = context.read<CartCubit>();
    cartCubit.addToCart(
      product: product,
      quantity: 1,
      restaurant: widget.restaurant,
    );
  }

  void _handleIncreaseQuantity(String itemId, int currentQuantity) {
    final cartCubit = context.read<CartCubit>();
    cartCubit.updateQuantity(itemId, currentQuantity + 1);
  }

  void _handleDecreaseQuantity(String itemId, int currentQuantity) {
    final cartCubit = context.read<CartCubit>();
    if (currentQuantity > 1) {
      cartCubit.updateQuantity(itemId, currentQuantity - 1);
    } else {
      cartCubit.removeItem(itemId);
    }
  }



  Widget? _buildCartFAB(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded || state.cart.isEmpty) {
          return const SizedBox.shrink();
        }

        final cart = state.cart;
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.shopping_cart),
          label: Text(
            '${cart.totalItems} items • ${cart.total.toStringAsFixed(0)} EGP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

/// Category tab bar delegate
class _CategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<CategoryEntity> categories;
  final String locale;

  _CategoryTabBarDelegate({
    required this.tabController,
    required this.categories,
    required this.locale,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: categories.map((category) {
          return Tab(text: category.getLocalizedName(locale));
        }).toList(),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// Modern product card
class ModernProductCard extends StatelessWidget {
  final ProductEntity product;
  final String locale;
  final String? branchId;
  final CartItemEntity? cartItem;
  final VoidCallback? onAddToCart;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const ModernProductCard({
    super.key,
    required this.product,
    required this.locale,
    this.branchId,
    this.cartItem,
    this.onAddToCart,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = branchId != null
        ? (product.branchAvailability[branchId] ?? product.isAvailable)
        : product.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: ProductImage(
                    imageUrl: product.imageUrl,
                    height: 100,
                    width: double.infinity,
                  ),
                ),
                if (product.discountedPrice != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: DiscountBadge(
                      percentage: ((product.price - product.discountedPrice!) /
                              product.price *
                              100)
                          .round(),
                    ),
                  ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.getLocalizedName(locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriceTag.small(
                          price: product.effectivePrice,
                          originalPrice: product.discountedPrice != null
                              ? product.price
                              : null,
                        ),
                        if (isAvailable)
                          cartItem == null
                              ? GestureDetector(
                                  onTap: onAddToCart,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : _buildQuantityControls(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrease,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${cartItem!.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrease,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
