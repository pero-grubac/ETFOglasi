import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/features/announcements/screen/announcement_screen.dart';
import 'package:etf_oglasi/features/announcements/screen/bookmarks_screen.dart';
import 'package:etf_oglasi/features/schedule/screen/schedule_screen.dart';
import 'package:etf_oglasi/features/settings/screen/error_log_screen.dart';
import 'package:etf_oglasi/features/settings/screen/notification_screen.dart';
import 'package:etf_oglasi/features/settings/screen/settings_screen.dart';
import 'package:flutter/material.dart';

import '../gen/app_localizations.dart';

class Routes {
  static const String announcementScreen = AnnouncementScreen.id;
  static const String scheduleScreen = ScheduleScreen.id;
  static const String settingsScreen = SettingsScreen.id;
  static const String notificationScreen = NotificationScreen.id;
  static const String errorLogScreen = ErrorLogScreen.id;
  static const String bookmarksScreen = BookmarksScreen.id;

  static String forCategory(Category category) {
    switch (category.type) {
      case CategoryType.announcements:
        return announcementScreen;
      case CategoryType.classSchedule:
      case CategoryType.roomSchedule:
        return scheduleScreen;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case announcementScreen:
        final category = settings.arguments as Category?;
        if (category != null && category.announcementsUrl != null) {
          return MaterialPageRoute(
            builder: (_) => AnnouncementScreen(category: category),
          );
        }
        return _errorRoute();
      case scheduleScreen:
        final category = settings.arguments as Category?;
        if (category != null && category.type != CategoryType.announcements) {
          return MaterialPageRoute(
            builder: (_) => ScheduleScreen(category: category),
          );
        }
        return _errorRoute();
      case settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case notificationScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case errorLogScreen:
        return MaterialPageRoute(builder: (_) => const ErrorLogScreen());
      case bookmarksScreen:
        return MaterialPageRoute(builder: (_) => const BookmarksScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        final locale = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(locale.error)),
          body: Center(child: Text(locale.routeNotFound)),
        );
      },
    );
  }
}
