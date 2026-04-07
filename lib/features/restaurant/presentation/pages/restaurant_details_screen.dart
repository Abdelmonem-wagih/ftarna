import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../branch/domain/repositories/branch_repository.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../widgets/product_card.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen>
    with SingleTickerProviderStateMixin {
  RestaurantEntity? _restaurant;
  BranchEntity? _selectedBranch;
  List<BranchEntity> _branches = [];
  List<CategoryEntity> _categories = [];
  Map<String, List<ProductEntity>> _productsByCategory = {};
  bool _isLoading = true;
  String? _error;
  TabController? _tabController;

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
      final restaurantRepo = sl<RestaurantRepository>();
      final branchRepo = sl<BranchRepository>();
      final categoryRepo = sl<CategoryRepository>();
      final productRepo = sl<ProductRepository>();

      // Load restaurant
      final restaurant = await restaurantRepo.getRestaurantById(widget.restaurantId);
      if (restaurant == null) {
        setState(() {
          _error = 'Restaurant not found';
          _isLoading = false;
        });
        return;
      }

      // Load branches
      final branches = await branchRepo.getBranchesByRestaurant(widget.restaurantId);

      // Select first open branch or first branch
      BranchEntity? selectedBranch;
      if (branches.isNotEmpty) {
        selectedBranch = branches.firstWhere(
          (b) => b.isOpen,
          orElse: () => branches.first,
        );
      }

      // Load categories
      final categories = await categoryRepo.getCategoriesByRestaurant(widget.restaurantId);

      // Load products for each category
      final productsByCategory = <String, List<ProductEntity>>{};
      for (final category in categories) {
        final products = await productRepo.getProductsByCategory(category.id);
        productsByCategory[category.id] = products;
      }

      setState(() {
        _restaurant = restaurant;
        _branches = branches;
        _selectedBranch = selectedBranch;
        _categories = categories;
        _productsByCategory = productsByCategory;
        _isLoading = false;

        if (_categories.isNotEmpty) {
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Restaurant not found')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(locale),
            if (_categories.isNotEmpty && _tabController != null)
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryTabsDelegate(
                  tabController: _tabController!,
                  categories: _categories,
                  locale: locale,
                ),
              ),
          ];
        },
        body: _categories.isEmpty
            ? const Center(child: Text('No menu available'))
            : TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final products = _productsByCategory[category.id] ?? [];
                  return _buildProductList(products, locale);
                }).toList(),
              ),
      ),
      floatingActionButton: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.cart.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${state.cart.totalItems} items • ${state.cart.total.toStringAsFixed(0)} EGP',
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSliverAppBar(String locale) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _restaurant!.getLocalizedName(locale),
          style: const TextStyle(
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_restaurant!.coverImageUrl != null)
              Image.network(
                _restaurant!.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              Container(color: Theme.of(context).primaryColor),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_branches.length > 1)
          PopupMenuButton<BranchEntity>(
            icon: const Icon(Icons.location_on),
            tooltip: 'Select Branch',
            onSelected: (branch) {
              setState(() {
                _selectedBranch = branch;
              });
            },
            itemBuilder: (context) {
              return _branches.map((branch) {
                return PopupMenuItem(
                  value: branch,
                  child: Row(
                    children: [
                      Icon(
                        branch.isOpen ? Icons.check_circle : Icons.cancel,
                        color: branch.isOpen ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(branch.getLocalizedName(locale)),
                    ],
                  ),
                );
              }).toList();
            },
          ),
      ],
    );
  }

  Widget _buildProductList(List<ProductEntity> products, String locale) {
    if (products.isEmpty) {
      return const Center(child: Text('No products in this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isAvailable = _selectedBranch != null
            ? product.isAvailableAtBranch(_selectedBranch!.id)
            : product.isAvailable;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            locale: locale,
            isAvailable: isAvailable,
            onAddToCart: isAvailable
                ? () => _addToCart(product)
                : null,
          ),
        );
      },
    );
  }

  void _addToCart(ProductEntity product) {
    if (_restaurant == null || _selectedBranch == null) return;

    context.read<CartCubit>().addToCart(
      product: product,
      quantity: 1,
      restaurant: _restaurant!,
      // branch: _selectedBranch!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.getLocalizedName(Localizations.localeOf(context).languageCode)} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<CategoryEntity> categories;
  final String locale;

  _CategoryTabsDelegate({
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
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
