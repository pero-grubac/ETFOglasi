import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/features/home/widget/category_grid_item.dart';
import 'package:etf_oglasi/features/settings/widget/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context);

    final categories = buildAvailableCategories(locale!, ref).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final categoryWidgets =
        categories.map((cat) => CategoryGridItem(category: cat)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.notifications),
      ),
      drawer: const MainDrawer(),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        children: categoryWidgets,
      ),
    );
  }
}
