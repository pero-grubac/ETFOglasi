import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/features/announcements/screen/announcement_screen.dart';
import 'package:etf_oglasi/features/schedule/screen/schedule_screen.dart';
import 'package:etf_oglasi/features/settings/screen/notification_screen.dart';
import 'package:etf_oglasi/features/settings/screen/settings_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String announcementScreen = AnnouncementScreen.id;
  static const String scheduleScreen = ScheduleScreen.id;
  static const String placeholderScreen = '/placeholder';
  static const String settingsScreen = SettingsScreen.id;
  static const String notificationScreen = NotificationScreen.id;
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
        final category = settings.arguments as Category?;
        if (category != null) {
          return MaterialPageRoute(
            builder: (_) => ScheduleScreen(
              category: category,
              settingsWidget: category.settingsWidget ?? const Placeholder(),
            ),
          );
        }
        return _errorRoute();
      case settingsScreen:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case notificationScreen:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
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
