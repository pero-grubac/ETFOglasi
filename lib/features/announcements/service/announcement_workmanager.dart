import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/notification_service.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/gen/app_localizations.dart';

const fetchNotificationTaskPrefix = "fetchNotificationTask_";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final key = inputData?['id'] as String?;
      final boardId = notificationBoardIds[key];
      if (key == null || boardId == null) return false;

      final prefs = await SharedPreferences.getInstance();
      // The background isolate may be reused; make sure settings changed in
      // the UI isolate are visible.
      await prefs.reload();

      final settings = NotificationTimeSetting.decodeMap(
        prefs.getString(LocalSettings.notificationTimeSettingsKey),
      );
      final setting = settings[key];
      if (setting == null || !setting.enabled) return true;

      final url = getAnnouncementsUrl(boardId);
      final newAnnouncements = await fetchNewAnnouncements(
        url: url,
        service: AnnouncementService(service: ApiService()),
        repository: AnnouncementRepository(dbHelper: DatabaseHelper()),
      );
      if (newAnnouncements.isEmpty) return true;

      final locale = lookupAppLocalizations(
        LocalSettings.toLocale(
          LocalSettings.parseLanguage(
            prefs.getString(LocalSettings.languageKey),
          ),
        ),
      );
      final notificationService = NotificationService();
      await notificationService.initialize(locale);
      await notificationService.showNewAnnouncements(
        id: int.parse(boardId),
        title: locale.newAnnouncementsTitle(
          board: notificationBoardTitle(locale, key),
          count: newAnnouncements.length,
        ),
        announcementTitles: newAnnouncements.map((a) => a.naslov).toList(),
        locale: locale,
        payload: boardId,
      );
      return true;
    } catch (_) {
      return false;
    }
  });
}

class AnnouncementWorkManager {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static String _taskName(String key) => '$fetchNotificationTaskPrefix$key';

  /// Registers tasks for enabled settings without touching tasks that are
  /// already scheduled (safe to call on every app start).
  static Future<void> ensurePeriodicTasks(
    Map<String, NotificationTimeSetting> settings,
  ) async {
    for (final entry in settings.entries) {
      if (entry.value.enabled) {
        await _register(entry.key, entry.value, ExistingWorkPolicy.keep);
      }
    }
  }

  /// Re-registers only the tasks whose settings changed.
  static Future<void> updatePeriodicTasks({
    required Map<String, NotificationTimeSetting> previous,
    required Map<String, NotificationTimeSetting> current,
  }) async {
    final keys = {...previous.keys, ...current.keys};
    for (final key in keys) {
      final before = previous[key];
      final after = current[key];
      if (before == after) continue;

      if (after == null || !after.enabled) {
        await Workmanager().cancelByUniqueName(_taskName(key));
      } else {
        await _register(key, after, ExistingWorkPolicy.replace);
      }
    }
  }

  static Future<void> _register(
    String key,
    NotificationTimeSetting setting,
    ExistingWorkPolicy policy,
  ) async {
    final totalMinutes = setting.totalMinutes.clamp(
      NotificationTimeSetting.minMinutes,
      999999,
    );
    await Workmanager().registerPeriodicTask(
      _taskName(key),
      _taskName(key),
      frequency: Duration(minutes: totalMinutes),
      initialDelay: const Duration(seconds: 10),
      existingWorkPolicy: policy,
      constraints: Constraints(networkType: NetworkType.connected),
      inputData: {'id': key},
    );
  }
}
