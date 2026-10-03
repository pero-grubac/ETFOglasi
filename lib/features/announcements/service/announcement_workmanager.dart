import 'dart:convert';

import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/service/notification_service.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/gen/app_localizations.dart';

/// The single periodic task that checks every enabled board.
const announcementCheckTask = 'announcementCheck';

/// Until 1.1.0 every board had its own task with this prefix.
const _legacyTaskPrefix = 'fetchNotificationTask_';

/// SharedPreferences: when each board was last checked successfully.
const lastBoardChecksKey = 'lastBoardChecks';

@pragma('vm:entry-point')
void callbackDispatcher() {
  // Any task name runs the check, so tasks left over from an older version
  // still work until the app cancels them on its next start. Checking twice
  // is harmless: boards that aren't due are skipped.
  Workmanager().executeTask((_, _) async {
    try {
      return await _checkDueBoards();
    } catch (e, stackTrace) {
      await errorLog.record(e, stackTrace, source: 'background');
      return !shouldRetryBackgroundError(e);
    }
  });
}

/// Checks the boards that are due and notifies about new announcements.
/// Returns `false` (WorkManager retries with backoff) when a board failed
/// for a reason that a retry can fix; boards that succeeded aren't due on
/// the retry.
Future<bool> _checkDueBoards() async {
  final prefs = await SharedPreferences.getInstance();
  // The background isolate may be reused; make sure settings changed in the
  // UI isolate are visible.
  await prefs.reload();

  final settings = NotificationTimeSetting.decodeMap(
    prefs.getString(LocalSettings.notificationTimeSettingsKey),
  );
  final frequency = checkFrequency(settings);
  if (frequency == null) return true;

  final now = DateTime.now();
  final lastChecks = decodeLastChecks(prefs.getString(lastBoardChecksKey));
  final due = dueBoards(
    settings: settings,
    lastChecks: lastChecks,
    now: now,
    frequency: frequency,
  );
  if (due.isEmpty) return true;

  final service = AnnouncementService(service: ApiService());
  final repository = AnnouncementRepository(dbHelper: DatabaseHelper());
  AppLocalizations? locale;
  NotificationService? notificationService;
  var retry = false;

  for (final key in due) {
    final boardId = notificationBoardIds[key]!;
    try {
      final announcements = notifiableAnnouncements(
        await fetchNewAnnouncements(
          url: getAnnouncementsUrl(boardId),
          service: service,
          repository: repository,
        ),
        now,
      );
      lastChecks[key] = now;
      if (announcements.isEmpty) continue;

      locale ??= lookupAppLocalizations(
        LocalSettings.toLocale(
          LocalSettings.parseLanguage(
            prefs.getString(LocalSettings.languageKey),
          ),
        ),
      );
      if (notificationService == null) {
        notificationService = NotificationService();
        await notificationService.initialize(locale);
      }
      await notificationService.showNewAnnouncements(
        id: int.parse(boardId),
        title: locale.newAnnouncementsTitle(
          board: notificationBoardTitle(locale, key),
          count: announcements.length,
        ),
        announcementTitles: announcements.map((a) => a.naslov).toList(),
        locale: locale,
        payload: boardId,
      );
    } catch (e, stackTrace) {
      // One failing board shouldn't stop the others.
      await errorLog.record(e, stackTrace, source: 'background ($key)');
      retry = retry || shouldRetryBackgroundError(e);
    }
  }

  await prefs.setString(lastBoardChecksKey, encodeLastChecks(lastChecks));
  return !retry;
}

/// Retrying only helps when the network or the server was the problem, not
/// for errors that will happen again (bad data, certificate, bugs).
bool shouldRetryBackgroundError(Object error) =>
    error is ApiException &&
    (error.kind == ApiErrorKind.network || error.kind == ApiErrorKind.server);

/// How often the task runs: the shortest interval of the enabled boards, or
/// `null` when none is enabled.
Duration? checkFrequency(Map<String, NotificationTimeSetting> settings) {
  int? minutes;
  for (final entry in settings.entries) {
    if (!entry.value.enabled || !notificationBoardIds.containsKey(entry.key)) {
      continue;
    }
    final value = entry.value.totalMinutes < NotificationTimeSetting.minMinutes
        ? NotificationTimeSetting.minMinutes
        : entry.value.totalMinutes;
    if (minutes == null || value < minutes) minutes = value;
  }
  return minutes == null ? null : Duration(minutes: minutes);
}

/// Enabled boards whose interval has passed since their last check.
///
/// WorkManager doesn't run exactly on time, so a board counts as due up to
/// half a task period early. Otherwise a run a minute early would push the
/// check back by a whole period.
List<String> dueBoards({
  required Map<String, NotificationTimeSetting> settings,
  required Map<String, DateTime> lastChecks,
  required DateTime now,
  required Duration frequency,
}) {
  final tolerance = frequency ~/ 2;
  final due = <String>[];
  for (final MapEntry(:key, value: setting) in settings.entries) {
    if (!setting.enabled || !notificationBoardIds.containsKey(key)) continue;
    final last = lastChecks[key];
    if (last == null ||
        now.difference(last) + tolerance >=
            Duration(minutes: setting.totalMinutes)) {
      due.add(key);
    }
  }
  return due;
}

/// New announcements worth a notification: expired ones are left out.
List<Announcement> notifiableAnnouncements(
  List<Announcement> announcements,
  DateTime now,
) => announcements.where((a) => !a.isExpiredAt(now)).toList();

Map<String, DateTime> decodeLastChecks(String? source) {
  if (source == null) return {};
  try {
    final decoded = json.decode(source) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        if (entry.value is int)
          entry.key: DateTime.fromMillisecondsSinceEpoch(entry.value as int),
    };
  } catch (_) {
    return {};
  }
}

String encodeLastChecks(Map<String, DateTime> lastChecks) => json.encode({
  for (final entry in lastChecks.entries)
    entry.key: entry.value.millisecondsSinceEpoch,
});

class AnnouncementWorkManager {
  /// Frequency (minutes) of the registered task, to know when it changed.
  static const _registeredMinutesKey = 'announcementCheckMinutes';
  static const _legacyTasksCancelledKey = 'legacyBoardTasksCancelled';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    await _cancelLegacyTasks();
  }

  static Future<void> _cancelLegacyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_legacyTasksCancelledKey) ?? false) return;
    for (final key in notificationBoardIds.keys) {
      await Workmanager().cancelByUniqueName('$_legacyTaskPrefix$key');
    }
    await prefs.setBool(_legacyTasksCancelledKey, true);
  }

  /// Makes the scheduled task match [settings]: registers it when missing,
  /// changes its frequency when needed, or cancels it when no board is
  /// enabled. Safe to call on every app start: an unchanged task keeps its
  /// schedule.
  static Future<void> syncPeriodicTask(
    Map<String, NotificationTimeSetting> settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final frequency = checkFrequency(settings);
    if (frequency == null) {
      await Workmanager().cancelByUniqueName(announcementCheckTask);
      await prefs.remove(_registeredMinutesKey);
      return;
    }

    final unchanged =
        prefs.getInt(_registeredMinutesKey) == frequency.inMinutes;
    await Workmanager().registerPeriodicTask(
      announcementCheckTask,
      announcementCheckTask,
      frequency: frequency,
      initialDelay: const Duration(seconds: 10),
      existingWorkPolicy: unchanged
          ? ExistingPeriodicWorkPolicy.keep
          : ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
    await prefs.setInt(_registeredMinutesKey, frequency.inMinutes);
  }
}
