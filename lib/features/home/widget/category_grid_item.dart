import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/core/ui/theme/category_grid_item_theme.dart';
import 'package:etf_oglasi/features/announcements/service/announcements_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

class CategoryGridItem extends ConsumerWidget {
  const CategoryGridItem({super.key, required this.category});
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryGridItemTheme = theme.extension<CategoryGridItemTheme>();
    final effectiveTheme =
        categoryGridItemTheme ??
        CategoryGridItemTheme(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          textStyle: theme.textTheme.titleLarge,
        );
    final url = category.announcementsUrl;
    final unseen = url != null
        ? ref.watch(unseenCountProvider(url)).valueOrNull ?? 0
        : 0;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.forCategory(category),
          arguments: category,
        );
      },
      splashColor: effectiveTheme.splashColor,
      borderRadius: effectiveTheme.decoration.borderRadius as BorderRadius?,
      child: Container(
        padding: effectiveTheme.padding,
        decoration: effectiveTheme.decoration,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.title,
                style: effectiveTheme.textStyle ?? theme.textTheme.titleLarge,
              ),
            ),
            if (unseen > 0)
              Align(
                alignment: Alignment.bottomRight,
                child: Semantics(
                  label: AppLocalizations.of(
                    context,
                  ).unseenAnnouncements(count: unseen),
                  child: ExcludeSemantics(
                    child: Badge.count(
                      count: unseen,
                      backgroundColor: Colors.amber,
                      textColor: Colors.black87,
                      largeSize: 24,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
