import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

const fetchNotificationTaskPrefix = "fetchNotificationTask_";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final container = ProviderContainer();
      try {
        final localSettings = container.read(localSettingsProvider);
        final id = inputData?['id'] as String?;

        if (id == null) {
          print('No ID provided for task $task');
          return Future.value(false);
        }

        final setting = localSettings.notificationTimeSettings[id];
        if (setting == null || !setting.enabled) {
          print('No valid or enabled setting for ID $id');
          return Future.value(false);
        }

        final url = getUrlForId(id);
        final service = container.read(announcementServiceProvider);

        try {
          final response = await service.fetchAnnouncements(url);
          print(
              'Successfully fetched announcements from $url for ID $id at ${DateTime.now()}');
          // TODO: Process response (e.g., trigger notifications)
        } catch (e) {
          print('Error fetching $url for ID $id: $e');
        }

        return Future.value(true);
      } finally {
        container.dispose();
      }
    } catch (e) {
      print('Error in Workmanager task $task: $e');
      return Future.value(false);
    }
  });
}

String getUrlForId(String id) {
  const urlMap = {
    'first_year': '1',
    'second_year': '3',
    'third_year': '4',
    'fourth_year': '5',
  };
  return getAnnouncementsUrl(urlMap[id] ?? '1');
}

class AnnouncementWorkManager {
  static Future<void> initialize() async {
    print('Initializing Workmanager');
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    print('Workmanager initialized');
  }

  static Future<void> registerPeriodicTasks(
      Map<String, NotificationTimeSetting> settings) async {
    print('Cancelling all existing Workmanager tasks');
    await Workmanager().cancelAll();
    print('All tasks cancelled, registering new tasks');

    for (final entry in settings.entries) {
      final id = entry.key;
      final setting = entry.value;

      if (setting.enabled) {
        final totalMinutes =
            (setting.days * 24 * 60 + setting.hours * 60 + setting.minutes)
                .clamp(15, 999999);
        print(
            'Registering task for ID $id with frequency $totalMinutes minutes');
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
        print('Task registered for ID $id');
      } else {
        print('Skipping task for ID $id: Not enabled');
      }
    }
    print('Finished registering tasks');
  }
}
