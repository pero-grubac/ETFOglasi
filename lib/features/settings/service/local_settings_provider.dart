import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
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
    );
  }

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    _saveSettings();
  }

  Future<void> updateNotificationsTimeSettings(
    Map<String, NotificationTimeSetting> settings,
  ) async {
    final previous = state.notificationTimeSettings;
    state = state.copyWith(notificationTimeSettings: settings);
    await _saveSettings();
    await AnnouncementWorkManager.updatePeriodicTasks(
      previous: previous,
      current: settings,
    );
  }

  void updateClassScheduleURL(String url) {
    state = state.copyWith(classScheduleUrl: url);
    _saveSettings();
  }

  void updateRoomScheduleId(String id) {
    state = state.copyWith(roomScheduleId: id);
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
