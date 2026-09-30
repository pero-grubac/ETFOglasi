import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/features/announcements/service/announcements_provider.dart';
import 'package:etf_oglasi/features/home/widget/category_grid_item.dart';
import 'package:etf_oglasi/features/settings/widget/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // The background check may have stored new announcements meanwhile.
    _lifecycleListener = AppLifecycleListener(
      onResume: () => ref.read(seenVersionProvider.notifier).bump(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final categories = buildAvailableCategories(locale);

    return Scaffold(
      appBar: AppBar(title: Text(locale.notifications)),
      drawer: const MainDrawer(),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        children: [
          for (final category in categories)
            CategoryGridItem(category: category),
        ],
      ),
    );
  }
}
