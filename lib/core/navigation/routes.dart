import 'package:flutter/material.dart';
import 'package:etf_oglasi/features/home/data/model/category.dart';

import 'package:etf_oglasi/features/announcements/presentation/screen/announcement_screen.dart';

class Routes {
  static const String announcementScreen = AnnouncementScreen.id;
  static const String scheduleScreen = '/schedule';
  static const String placeholderScreen = '/placeholder';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case announcementScreen:
        final category = settings.arguments as Category?;
        if (category != null) {
          return MaterialPageRoute(
            builder: (_) => AnnouncementScreen(category: category),
          );
        }
        return _errorRoute();
      case scheduleScreen:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
        );
      case placeholderScreen:
        final category = settings.arguments as Category?;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(category?.title ?? 'Unknown')),
            body: Center(
                child: Text('Coming Soon: ${category?.title ?? 'Unknown'}')),
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Route not found')),
      ),
    );
  }
}
