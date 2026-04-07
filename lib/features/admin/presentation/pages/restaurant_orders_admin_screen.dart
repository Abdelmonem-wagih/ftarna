import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../cubit/restaurant_orders_cubit.dart';
import '../widgets/aggregated_items_section.dart';
import '../widgets/users_list_section.dart';
import 'unpaid_orders_management_screen.dart';

/// Main Admin Screen for Restaurant Orders Management
/// Shows aggregated items and users list with real-time updates
class RestaurantOrdersAdminScreen extends StatelessWidget {
  const RestaurantOrdersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.currentUser;

    if (user == null || user.restaurantId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No restaurant assigned to this admin'),
        ),
      );
    }

    return BlocProvider(
      create: (context) => RestaurantOrdersCubit(sl<OrderRepository>())
        ..loadRestaurantOrders(user.restaurantId!),
      child: const _RestaurantOrdersAdminView(),
    );
  }
}

class _RestaurantOrdersAdminView extends StatefulWidget {
  const _RestaurantOrdersAdminView();

  @override
  State<_RestaurantOrdersAdminView> createState() => _RestaurantOrdersAdminViewState();
}

class _RestaurantOrdersAdminViewState extends State<_RestaurantOrdersAdminView> {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFab) {
      setState(() => _showFab = true);
    } else if (_scrollController.offset <= 200 && _showFab) {
      setState(() => _showFab = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.admin,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
              builder: (context, state) {
                if (state is RestaurantOrdersLoaded) {
                  return Text(
                    '${state.totalOrders} ${context.l10n.orders} • ${state.totalItems} Items',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          // Batch Update Status Button
          BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
            builder: (context, state) {
              if (state is RestaurantOrdersLoaded) {
                final nextStatus = state.nextGlobalStatus;
                if (nextStatus != null) {
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.update),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    tooltip: _getStatusUpdateTooltip(nextStatus),
                    onPressed: () => _showBatchUpdateConfirmation(context, state, nextStatus),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          // Unpaid Orders Badge
          BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
            builder: (context, state) {
              if (state is RestaurantOrdersLoaded) {
                final unpaidCount = state.usersWithUnpaidOrders.length;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.payment_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RestaurantOrdersCubit>(),
                              child: const UnpaidOrdersManagementScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    if (unpaidCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$unpaidCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<RestaurantOrdersCubit, RestaurantOrdersState>(
        builder: (context, state) {
          if (state is RestaurantOrdersLoading) {
            return const PageLoading();
          }

          if (state is RestaurantOrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is RestaurantOrdersLoaded) {
            if (state.allOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.noOrders,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Real-time stream will auto-refresh
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Summary Cards
                  SliverToBoxAdapter(
                    child: _buildSummaryCards(state),
                  ),

                  // Aggregated Items Section
                  SliverToBoxAdapter(
                    child: AggregatedItemsSection(
                      items: state.aggregatedItems,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 8),
                  ),

                  // Users List Section
                  UsersListSection(
                    usersSummaries: state.usersSummaries,
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildSummaryCards(RestaurantOrdersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: context.l10n.total,
                  value: '${state.totalRevenue.toStringAsFixed(0)} EGP',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: context.l10n.paid,
                  value: '${state.totalPaid.toStringAsFixed(0)} EGP',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: context.l10n.notPaid,
                  value: '${state.totalUnpaid.toStringAsFixed(0)} EGP',
                  icon: Icons.pending_outlined,
                  color: AppTheme.warningColor,
                  highlight: state.totalUnpaid > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Users',
                  value: '${state.usersSummaries.length}',
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusUpdateTooltip(OrderStatus nextStatus) {
    switch (nextStatus) {
      case OrderStatus.confirmed:
        return 'Confirm All Orders';
      case OrderStatus.arrived:
        return 'Mark All as Arrived';
      default:
        return 'Update All Orders';
    }
  }

  void _showBatchUpdateConfirmation(
    BuildContext context,
    RestaurantOrdersLoaded state,
    OrderStatus nextStatus,
  ) {
    final activeOrders = state.allOrders
        .where((o) => !o.isCancelled && o.status != OrderStatus.arrived && o.status.nextStatus != null)
        .toList();

    if (activeOrders.isEmpty) {
      context.showErrorSnackBar('No orders to update');
      return;
    }

    final currentStatus = state.globalStatus;
    final statusName = _getStatusName(nextStatus);
    final currentStatusName = currentStatus != null ? _getStatusName(currentStatus) : 'current';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.update,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Update All Orders'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to update all orders?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag, size: 20, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${activeOrders.length} orders will be updated',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(currentStatus ?? OrderStatus.pending),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          currentStatusName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(nextStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ This action will notify all users',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.warningColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final cubit = context.read<RestaurantOrdersCubit>();
              final authCubit = context.read<AuthCubit>();
              final updatedBy = authCubit.currentUser?.name ?? 'Admin';

              try {
                await cubit.updateAllOrdersToNextStatus(updatedBy: updatedBy);
                if (context.mounted) {
                  context.showSuccessSnackBar('✅ All orders updated to $statusName');
                }
              } catch (e) {
                if (context.mounted) {
                  context.showErrorSnackBar('Failed to update orders: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Update'),
          ),
        ],
      ),
    );
  }

  String _getStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warningColor;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.arrived:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
        return AppTheme.errorColor;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: color, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: highlight ? color : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
