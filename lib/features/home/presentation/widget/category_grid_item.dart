import 'package:etf_oglasi/core/ui/theme/category_grid_item_theme.dart';
import 'package:flutter/material.dart';

import 'package:etf_oglasi/features/home/data/model/category.dart';

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({
    super.key,
    required this.category,
  });
  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryGridItemTheme = theme.extension<CategoryGridItemTheme>();
    final effectiveTheme = categoryGridItemTheme ??
        CategoryGridItemTheme(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          splashColor: theme.colorScheme.primary.withOpacity(0.3),
          textStyle: theme.textTheme.titleLarge,
        );

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          category.route.settings.name!,
          arguments: category,
        );
      },
      splashColor: effectiveTheme.splashColor,
      borderRadius: effectiveTheme.decoration.borderRadius as BorderRadius?,
      child: Container(
        padding: effectiveTheme.padding,
        decoration: effectiveTheme.decoration,
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            category.title,
            style: effectiveTheme.textStyle ?? theme.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
