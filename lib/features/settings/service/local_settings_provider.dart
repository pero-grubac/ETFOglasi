import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/schedule/service/saved_schedule_sync.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsNotifier extends Notifier<LocalSettings> {
  @override
  LocalSettings build() => const LocalSettings();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = LocalSettings(
      themeMode: LocalSettings.parseThemeMode(
        prefs.getString(LocalSettings.themeModeKey),
      ),
      language: LocalSettings.parseLanguage(
        prefs.getString(LocalSettings.languageKey),
      ),
      classScheduleUrl: prefs.getString(LocalSettings.classScheduleUrlKey),
      roomScheduleId: prefs.getString(LocalSettings.roomScheduleIdKey),
      notificationTimeSettings: NotificationTimeSetting.decodeMap(
        prefs.getString(LocalSettings.notificationTimeSettingsKey),
      ),
      checkForUpdates: prefs.getBool(LocalSettings.checkForUpdatesKey) ?? true,
      classReminderMinutes:
          prefs.getInt(LocalSettings.classReminderMinutesKey) ?? 0,
    );
  }

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
    // Reminder and widget texts are in the app's language.
    await ref.read(savedScheduleSyncProvider).sync();
  }

  Future<void> updateNotificationsTimeSettings(
    Map<String, NotificationTimeSetting> settings,
  ) async {
    state = state.copyWith(notificationTimeSettings: settings);
    await _saveSettings();
    await AnnouncementWorkManager.syncPeriodicTask(settings);
  }

  Future<void> updateClassScheduleURL(String url) async {
    state = state.copyWith(classScheduleUrl: url);
    await _saveSettings();
    await ref.read(savedScheduleSyncProvider).sync();
  }

  Future<void> updateClassReminderMinutes(int minutes) async {
    state = state.copyWith(classReminderMinutes: minutes);
    await _saveSettings();
    await ref.read(savedScheduleSyncProvider).sync();
  }

  void updateRoomScheduleId(String id) {
    state = state.copyWith(roomScheduleId: id);
    _saveSettings();
  }

  void updateCheckForUpdates(bool enabled) {
    state = state.copyWith(checkForUpdates: enabled);
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      LocalSettings.themeModeKey,
      LocalSettings.themeModeToString(state.themeMode),
    );
    await prefs.setString(LocalSettings.languageKey, state.language);
    await _setOrRemove(
      prefs,
      LocalSettings.classScheduleUrlKey,
      state.classScheduleUrl,
    );
    await _setOrRemove(
      prefs,
      LocalSettings.roomScheduleIdKey,
      state.roomScheduleId,
    );
    await prefs.setString(
      LocalSettings.notificationTimeSettingsKey,
      NotificationTimeSetting.encodeMap(state.notificationTimeSettings),
    );
    await prefs.setBool(
      LocalSettings.checkForUpdatesKey,
      state.checkForUpdates,
    );
    await prefs.setInt(
      LocalSettings.classReminderMinutesKey,
      state.classReminderMinutes,
    );
  }

  Future<void> _setOrRemove(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}

final localSettingsProvider =
    NotifierProvider<LocalSettingsNotifier, LocalSettings>(
      LocalSettingsNotifier.new,
    );

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(localSettingsProvider.select((s) => s.themeMode)),
);

final localeProvider = Provider<Locale>(
  (ref) => LocalSettings.toLocale(
    ref.watch(localSettingsProvider.select((s) => s.language)),
  ),
);
