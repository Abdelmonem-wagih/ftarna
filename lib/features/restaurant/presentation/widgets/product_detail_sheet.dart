import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../restaurant/domain/entities/restaurant_entity.dart';

class ProductDetailSheet extends StatefulWidget {
  final ProductEntity product;
  final RestaurantEntity restaurant;
  // final BranchEntity branch;

  const ProductDetailSheet({
    super.key,
    required this.product,
    required this.restaurant,
    // required this.branch,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _quantity = 1;
  final Map<String, List<String>> _selectedVariations = {};
  final TextEditingController _instructionsController = TextEditingController();
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    // Initialize default selections for required groups
    for (final group in widget.product.variationGroups) {
      if (group.isRequired && group.variations.isNotEmpty) {
        final defaultVariation = group.variations.firstWhere(
          (v) => v.isDefault,
          orElse: () => group.variations.first,
        );
        _selectedVariations[group.id] = [defaultVariation.id];
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double total = widget.product.effectivePrice;

    for (final entry in _selectedVariations.entries) {
      final group = widget.product.variationGroups.firstWhere(
        (g) => g.id == entry.key,
        orElse: () => widget.product.variationGroups.first,
      );

      for (final variationId in entry.value) {
        final variation = group.variations.firstWhere(
          (v) => v.id == variationId,
          orElse: () => group.variations.first,
        );
        total += variation.priceModifier;
      }
    }

    return total * _quantity;
  }

  bool get _canAddToCart {
    // Check all required groups have selections
    for (final group in widget.product.variationGroups) {
      if (group.isRequired) {
        if (!_selectedVariations.containsKey(group.id) ||
            _selectedVariations[group.id]!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  List<SelectedVariation> _buildSelectedVariations() {
    final List<SelectedVariation> result = [];

    for (final entry in _selectedVariations.entries) {
      final group = widget.product.variationGroups.firstWhere(
        (g) => g.id == entry.key,
      );

      for (final variationId in entry.value) {
        final variation = group.variations.firstWhere(
          (v) => v.id == variationId,
        );

        result.add(SelectedVariation(
          groupId: group.id,
          groupNameAr: group.nameAr,
          groupNameEn: group.nameEn,
          variationId: variation.id,
          variationNameAr: variation.nameAr,
          variationNameEn: variation.nameEn,
          priceModifier: variation.priceModifier,
        ));
      }
    }

    return result;
  }

  void _addToCart() async {
    if (!_canAddToCart || _isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      context.read<CartCubit>().addToCart(
            product: widget.product,
            quantity: _quantity,
            restaurant: widget.restaurant,
            // branch: widget.branch,
            selectedVariations: _buildSelectedVariations(),
            specialInstructions: _instructionsController.text.isNotEmpty
                ? _instructionsController.text
                : null,
          );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isAddingToCart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImage(
                      imageUrl: widget.product.imageUrl,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.getLocalizedName(locale),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.product.getLocalizedDescription(locale) !=
                                null) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.product.getLocalizedDescription(locale)!,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PriceTag.large(
                        price: widget.product.effectivePrice,
                        originalPrice: widget.product.discountedPrice != null
                            ? widget.product.price
                            : null,
                      ),
                    ],
                  ),
                  // Variation groups
                  if (widget.product.variationGroups.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ...widget.product.variationGroups.map((group) {
                      return _buildVariationGroup(group, locale);
                    }),
                  ],
                  // Special instructions
                  const SizedBox(height: 24),
                  Text(
                    'Special Instructions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'E.g., No onions, extra sauce...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationGroup(VariationGroup group, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              group.getLocalizedName(locale),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (group.isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (group.allowMultiple && group.maxSelections != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Select up to ${group.maxSelections}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.variations.map((variation) {
            final isSelected =
                _selectedVariations[group.id]?.contains(variation.id) ?? false;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (group.allowMultiple) {
                    final current = _selectedVariations[group.id] ?? [];
                    if (isSelected) {
                      current.remove(variation.id);
                    } else {
                      if (group.maxSelections == null ||
                          current.length < group.maxSelections!) {
                        current.add(variation.id);
                      }
                    }
                    _selectedVariations[group.id] = current;
                  } else {
                    _selectedVariations[group.id] = [variation.id];
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      variation.getLocalizedName(locale),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (variation.priceModifier > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '+${variation.priceModifier.toInt()} EGP',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Bottom bar for product detail (can be used as overlay)
class ProductDetailBottomBar extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final double totalPrice;
  final VoidCallback onAddToCart;
  final bool isLoading;
  final bool canAdd;

  const ProductDetailBottomBar({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.totalPrice,
    required this.onAddToCart,
    this.isLoading = false,
    this.canAdd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            QuantitySelector(
              quantity: quantity,
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: canAdd && !isLoading ? onAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${totalPrice.toStringAsFixed(0)} EGP',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
