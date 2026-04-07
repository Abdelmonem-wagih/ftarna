import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../cubit/admin_cubit.dart';

class AdminAggregationTab extends StatelessWidget {
  const AdminAggregationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          if (state.aggregatedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
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

          // Sort by quantity descending
          final sortedItems = state.aggregatedItems.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final totalItems = sortedItems.fold(0, (sum, item) => sum + item.value);

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.list_alt,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.aggregatedItems,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.l10n.totalItems(totalItems),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _AggregationItemCard(
                      name: item.key,
                      quantity: item.value,
                      isTop: index < 3,
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AggregationItemCard extends StatelessWidget {
  final String name;
  final int quantity;
  final bool isTop;

  const _AggregationItemCard({
    required this.name,
    required this.quantity,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isTop ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isTop
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant,
                color: isTop ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isTop
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'x$quantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isTop ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
