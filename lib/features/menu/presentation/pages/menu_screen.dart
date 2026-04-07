import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../session/presentation/cubit/session_cubit.dart';
import '../../../order/presentation/cubit/order_cubit.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../common/widgets/menu_item_card.dart';
import '../../../common/widgets/session_banner.dart';
import '../cubit/menu_cubit.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().loadActiveMenuItems();
    context.read<SessionCubit>().loadCurrentSession();

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderCubit>().loadUserOrder(authState.user.id);
    }
  }

  void _submitOrder() {
    final authState = context.read<AuthCubit>().state;
    final sessionState = context.read<SessionCubit>().state;
    final menuState = context.read<MenuCubit>().state;

    if (authState is! AuthAuthenticated) return;
    if (sessionState is! SessionLoaded || sessionState.session == null) return;
    if (menuState is! MenuLoaded) return;

    if (menuState.selectedQuantities.isEmpty) {
      context.showErrorSnackBar(context.l10n.noItemsSelected);
      return;
    }

    context.read<OrderCubit>().submitOrder(
      sessionId: sessionState.session!.id,
      userId: authState.user.id,
      userName: authState.user.name,
      menuItems: menuState.items,
      selectedQuantities: menuState.selectedQuantities,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.menu),
      ),
      body: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSubmitted) {
            context.showSuccessSnackBar(context.l10n.orderSubmitted);
            context.read<MenuCubit>().clearSelections();
          } else if (state is OrderError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Column(
          children: [
            // Session banner
            BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
                if (state is SessionLoaded) {
                  return SessionBanner(session: state.session);
                }
                return const SizedBox.shrink();
              },
            ),
            // Menu items
            Expanded(
              child: BlocBuilder<MenuCubit, MenuState>(
                builder: (context, menuState) {
                  if (menuState is MenuLoading) {
                    return const LoadingWidget();
                  }

                  if (menuState is MenuError) {
                    return Center(child: Text(menuState.message));
                  }

                  if (menuState is MenuLoaded) {
                    return _buildMenuList(menuState);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            // Order summary
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(MenuLoaded state) {
    if (state.items.isEmpty) {
      return Center(
        child: Text(context.l10n.noMenuItems),
      );
    }

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        final canOrder = sessionState is SessionLoaded &&
            sessionState.session != null &&
            sessionState.session!.canOrder;

        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            final hasOrder = orderState is OrderLoaded &&
                orderState.currentOrder != null &&
                !orderState.currentOrder!.isCancelled;

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final quantity = state.selectedQuantities[item.id] ?? 0;

                return MenuItemCard(
                  item: item,
                  quantity: quantity,
                  enabled: canOrder && !hasOrder,
                  onIncrement: () {
                    context.read<MenuCubit>().incrementQuantity(item.id);
                  },
                  onDecrement: () {
                    context.read<MenuCubit>().decrementQuantity(item.id);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, menuState) {
        if (menuState is! MenuLoaded) return const SizedBox.shrink();

        return BlocBuilder<SessionCubit, SessionState>(
          builder: (context, sessionState) {
            final canOrder = sessionState is SessionLoaded &&
                sessionState.session != null &&
                sessionState.session!.canOrder;

            return BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                final hasOrder = orderState is OrderLoaded &&
                    orderState.currentOrder != null &&
                    !orderState.currentOrder!.isCancelled;
                final isSubmitting = orderState is OrderSubmitting;

                if (hasOrder) {
                  return _buildExistingOrderBanner(orderState);
                }

                if (menuState.totalSelectedItems == 0) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${menuState.totalSelectedItems} ${context.l10n.items}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${menuState.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canOrder && !isSubmitting ? _submitOrder : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(context.l10n.submitOrder),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExistingOrderBanner(OrderState state) {
    final orderLoaded = state as OrderLoaded;
    final order = orderLoaded.currentOrder!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: AppTheme.successColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.orderSubmitted,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                  Text(
                    '${order.totalItems} ${context.l10n.items} • ${order.totalPrice.toStringAsFixed(2)} ${context.l10n.egp}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successColor.withValues(alpha: 0.8),
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
