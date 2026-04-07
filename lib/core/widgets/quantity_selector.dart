import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern quantity selector widget
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minQuantity;
  final int maxQuantity;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.size = 36,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onTap: quantity > minQuantity
                ? () => onChanged(quantity - 1)
                : null,
          ),
          SizedBox(
            width: size,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onTap: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

/// Compact quantity selector (inline)
class CompactQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minQuantity;
  final int maxQuantity;

  const CompactQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 0,
    this.maxQuantity = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: quantity <= minQuantity ? Icons.delete_outline : Icons.remove,
          onTap: quantity > minQuantity
              ? () => onChanged(quantity - 1)
              : (quantity == minQuantity && minQuantity == 0)
                  ? () => onChanged(-1) // Signal to remove item
                  : null,
          isDelete: quantity <= minQuantity && minQuantity == 0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            quantity.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        _buildIconButton(
          icon: Icons.add,
          onTap: quantity < maxQuantity
              ? () => onChanged(quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isDelete = false,
  }) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDelete
                  ? AppTheme.errorColor.withOpacity(0.1)
                  : AppTheme.primaryColor.withOpacity(0.1))
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? (isDelete ? AppTheme.errorColor : AppTheme.primaryColor)
              : Colors.grey.shade400,
          size: 18,
        ),
      ),
    );
  }
}

/// Add to cart button with quantity
class AddToCartButton extends StatelessWidget {
  final int quantity;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onQuantityChanged;
  final bool isLoading;

  const AddToCartButton({
    super.key,
    required this.quantity,
    this.onAdd,
    this.onQuantityChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: isLoading ? null : onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 4),
                    Text('Add'),
                  ],
                ),
        ),
      );
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: quantity == 1 ? Icons.delete_outline : Icons.remove,
            onTap: () => onQuantityChanged?.call(quantity - 1),
            isDelete: quantity == 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onTap: () => onQuantityChanged?.call(quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDelete ? AppTheme.errorColor : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
