import 'package:etf_oglasi/core/constants/strings.dart';
import 'package:etf_oglasi/features/home/data/model/category.dart';
import 'package:etf_oglasi/features/home/presentation/widget/category_grid_item.dart';
import 'package:etf_oglasi/features/settings/presentation/widget/main_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = List<Category>.from(availableCategories)
      ..sort((a, b) => a.id.compareTo(b.id));
    final categoryWidgets =
        categories.map((cat) => CategoryGridItem(category: cat)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(GeneralStrings.announcements),
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
