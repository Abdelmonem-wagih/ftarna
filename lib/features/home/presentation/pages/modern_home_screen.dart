import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/pages/modern_cart_screen.dart';
import '../../../restaurant/presentation/pages/modern_restaurant_list_screen.dart';
import '../../../order/presentation/pages/orders_list_screen.dart';
import '../../../admin/presentation/pages/restaurant_orders_admin_screen.dart';
import 'settings_page.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final isAdmin = state.user.isAdmin;
        final screens = [
          const ModernRestaurantListScreen(),
          const OrdersListScreen(),
          if (isAdmin) const RestaurantOrdersAdminScreen(),
          const SettingsPage(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: _buildBottomNavBar(context, isAdmin),
          floatingActionButton: _buildCartFAB(context),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isAdmin) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.restaurant_menu_outlined,
                activeIcon: Icons.restaurant_menu,
                label: context.l10n.menu,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: context.l10n.myOrder,
              ),
              if (isAdmin)
                _buildNavItem(
                  index: 2,
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  label: context.l10n.admin,
                ),
              _buildNavItem(
                index: isAdmin ? 3 : 2,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: context.l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildCartFAB(BuildContext context) {
    // Only show cart FAB on restaurant list screen
    if (_currentIndex != 0) return null;

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
              MaterialPageRoute(
                builder: (context) => const ModernCartScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cart.totalItems.toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: Text(
            '${cart.total.toStringAsFixed(0)} EGP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
