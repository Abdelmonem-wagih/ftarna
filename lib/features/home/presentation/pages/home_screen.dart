import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../menu/presentation/pages/menu_screen.dart';
import '../../../order/presentation/pages/my_order_screen.dart';
import '../../../admin/presentation/pages/admin_panel_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          const MenuScreen(),
          const MyOrderScreen(),
          if (isAdmin) const AdminPanelScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(Icons.restaurant_menu),
                label: context.l10n.menu,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: context.l10n.myOrder,
              ),
              if (isAdmin)
                NavigationDestination(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: const Icon(Icons.admin_panel_settings),
                  label: context.l10n.admin,
                ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: context.l10n.settings,
              ),
            ],
          ),
        );
      },
    );
  }
}
