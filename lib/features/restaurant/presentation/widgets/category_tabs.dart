import 'package:flutter/material.dart';

import '../../../category/domain/entities/category_entity.dart';

class CategoryTabs extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String locale;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.locale,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.getLocalizedName(locale)),
              selected: isSelected,
              onSelected: (_) => onTabSelected(index),
            ),
          );
        },
      ),
    );
  }
}
