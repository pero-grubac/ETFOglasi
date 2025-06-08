import 'dart:convert';

import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const fetchNotificationTaskPrefix = "fetchNotificationTask_";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = inputData?['id'] as String?;
      if (id == null) {
        return Future.value(false);
      }

      final notificationTimeSettingsJson =
          prefs.getString('notificationTimeSettings');
      if (notificationTimeSettingsJson == null) {
        return Future.value(false);
      }

      final decoded =
          json.decode(notificationTimeSettingsJson) as Map<String, dynamic>;
      final map = decoded.map(
        (key, value) => MapEntry(key, NotificationTimeSetting.fromMap(value)),
      );

      final setting = map[id];
      if (setting == null || !setting.enabled) {
        return Future.value(false);
      }

      final url = getUrlForId(id);

      final service = AnnouncementService(service: ApiService());
      final repository = AnnouncementRepository(dbHelper: DatabaseHelper());

      // Plugin
      final FlutterLocalNotificationsPlugin notificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await notificationsPlugin.initialize(initializationSettings);

      final language = prefs.getString('language') ?? LocalSettings.srLatLang;
      print('lang ' + language);
      try {
        await fetchAndCompareAnnouncements(
          url: url,
          service: service,
          repository: repository,
          notificationsPlugin: notificationsPlugin,
          language: language,
        );
      } catch (e) {
        return Future.value(false);
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

String getUrlForId(String id) {
  const urlMap = {
    'first_year': '1',
    'second_year': '2',
    'third_year': '3',
    'fourth_year': '4',
  };
  return getAnnouncementsUrl(urlMap[id] ?? '1');
}

class AnnouncementWorkManager {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  static Future<void> registerPeriodicTasks(
      Map<String, NotificationTimeSetting> settings) async {
    await Workmanager().cancelAll();

    for (final entry in settings.entries) {
      final id = entry.key;
      final setting = entry.value;

      if (setting.enabled) {
        final totalMinutes =
            (setting.days * 24 * 60 + setting.hours * 60 + setting.minutes)
                .clamp(15, 999999);

        await Workmanager().registerPeriodicTask(
          "$fetchNotificationTaskPrefix$id",
          "$fetchNotificationTaskPrefix$id",
          frequency: Duration(minutes: totalMinutes),
          initialDelay: const Duration(seconds: 10),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
          ),
          inputData: {'id': id},
        );
      }
    }
  }
}
