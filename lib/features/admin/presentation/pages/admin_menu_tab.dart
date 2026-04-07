import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../menu/presentation/cubit/menu_cubit.dart';

class AdminMenuTab extends StatefulWidget {
  const AdminMenuTab({super.key});

  @override
  State<AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<AdminMenuTab> {
  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().loadAllMenuItems();
  }

  void _showAddEditDialog([MenuItemEntity? item]) {
    showDialog(
      context: context,
      builder: (dialogContext) => _MenuItemDialog(
        item: item,
        onSave: (name, price, isActive) {
          final menuCubit = context.read<MenuCubit>();
          if (item == null) {
            // Add new item
            menuCubit.addMenuItem(MenuItemEntity(
              id: '',
              name: name,
              price: price,
              isActive: isActive,
              createdAt: DateTime.now(),
            ));
          } else {
            // Update existing item
            menuCubit.updateMenuItem(item.copyWith(
              name: name,
              price: price,
              isActive: isActive,
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MenuLoaded) {
          return Column(
            children: [
              // Add button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      context.l10n.menuManagement,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addItem),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items list
              Expanded(
                child: state.items.isEmpty
                    ? Center(
                        child: Text(context.l10n.noMenuItems),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _MenuItemAdminCard(
                            item: item,
                            onEdit: () => _showAddEditDialog(item),
                            onToggleActive: () {
                              if (item.isActive) {
                                context.read<MenuCubit>().archiveMenuItem(item.id);
                              } else {
                                context.read<MenuCubit>().activateMenuItem(item.id);
                              }
                            },
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

class _MenuItemAdminCard extends StatelessWidget {
  final MenuItemEntity item;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const _MenuItemAdminCard({
    required this.item,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant,
            color: item.isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: item.isActive ? null : AppTheme.textSecondary,
            decoration: item.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '${item.price.toStringAsFixed(2)} ${context.l10n.egp}',
          style: TextStyle(
            color: item.isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                item.isActive ? Icons.visibility : Icons.visibility_off,
                color: item.isActive ? AppTheme.successColor : AppTheme.textSecondary,
              ),
              onPressed: onToggleActive,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemDialog extends StatefulWidget {
  final MenuItemEntity? item;
  final Function(String name, double price, bool isActive) onSave;

  const _MenuItemDialog({
    this.item,
    required this.onSave,
  });

  @override
  State<_MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<_MenuItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price.toString() ?? '',
    );
    _isActive = widget.item?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;

    if (name.isEmpty || price <= 0) {
      return;
    }

    widget.onSave(name, price, _isActive);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return AlertDialog(
      title: Text(isEdit ? context.l10n.editItem : context.l10n.addItem),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: context.l10n.itemName,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.itemPrice,
              suffixText: context.l10n.egp,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(context.l10n.itemActive),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
