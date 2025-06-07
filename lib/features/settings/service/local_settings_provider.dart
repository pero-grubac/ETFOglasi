import 'dart:convert';

import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/schedule/service/class_schedule_url_notifier.dart';
import 'package:etf_oglasi/features/schedule/service/room_schedule_url_notifier.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/locale_notifier.dart';
import 'package:etf_oglasi/features/settings/service/notifications_time_notifier.dart';
import 'package:etf_oglasi/features/settings/service/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsNotifier extends StateNotifier<LocalSettings> {
  final Ref ref;
  LocalSettingsNotifier(this.ref)
      : super(LocalSettings(
          language: LocalSettings.srLatLang,
          themeMode: LocalSettings.darkMode,
          notificationTimeSettings: {},
        )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode') ?? LocalSettings.lightMode;
    final language = prefs.getString('language') ?? LocalSettings.srLatLang;
    final String? classScheduleUrl = prefs.getString('classScheduleUrl');
    final String? roomScheduleId = prefs.getString('roomScheduleId');

    final notificationTimeSettingsJson =
        prefs.getString('notificationTimeSettings');
    Map<String, NotificationTimeSetting> notificationTimeSettings = {};
    if (notificationTimeSettingsJson != null) {
      final decoded =
          json.decode(notificationTimeSettingsJson) as Map<String, dynamic>;
      notificationTimeSettings = decoded.map(
        (key, value) => MapEntry(
          key,
          NotificationTimeSetting.fromMap(value),
        ),
      );
    }

    state = LocalSettings(
      themeMode: themeMode,
      language: language,
      classScheduleUrl: classScheduleUrl,
      roomScheduleId: roomScheduleId,
      notificationTimeSettings: notificationTimeSettings,
    );
    await AnnouncementWorkManager.registerPeriodicTasks(
        notificationTimeSettings);

    final themeModeEnum =
        themeMode == LocalSettings.darkMode ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeNotifierProvider.notifier).setTheme(themeModeEnum);

    final locale = parseLocale(language);
    ref.read(localeProvider.notifier).updateLocale(locale);
  }

  void updateTheme(String themeMode) {
    state = LocalSettings(
      themeMode: themeMode,
      language: state.language,
      classScheduleUrl: state.classScheduleUrl,
      roomScheduleId: state.roomScheduleId,
      notificationTimeSettings: state.notificationTimeSettings,
    );
    _saveSettings();

    final themeModeEnum =
        themeMode == LocalSettings.darkMode ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeNotifierProvider.notifier).setTheme(themeModeEnum);
  }

  void updateLanguage(String language) {
    state = LocalSettings(
      themeMode: state.themeMode,
      language: language,
      classScheduleUrl: state.classScheduleUrl,
      roomScheduleId: state.roomScheduleId,
      notificationTimeSettings: state.notificationTimeSettings,
    );
    _saveSettings();

    final locale = parseLocale(language);
    ref.read(localeProvider.notifier).updateLocale(locale);
  }

  void updateNotificationsTimeSettings(
      Map<String, NotificationTimeSetting> map) {
    state = LocalSettings(
      language: state.language,
      themeMode: state.themeMode,
      classScheduleUrl: state.classScheduleUrl,
      roomScheduleId: state.roomScheduleId,
      notificationTimeSettings: map,
    );
    _saveSettings();
    ref
        .read(notificationsTimeNotifierProvider.notifier)
        .updateNotificationsTime(map);
    AnnouncementWorkManager.registerPeriodicTasks(map);
  }

  void updateClassScheduleURL(String url) {
    state = LocalSettings(
      language: state.language,
      themeMode: state.themeMode,
      classScheduleUrl: url,
      notificationTimeSettings: state.notificationTimeSettings,
    );
    _saveSettings();
    ref.read(classScheduleURLProvider.notifier).updateUrl(url);
  }

  void updateRoomScheduleId(String id) {
    state = LocalSettings(
      language: state.language,
      themeMode: state.themeMode,
      classScheduleUrl: state.classScheduleUrl,
      roomScheduleId: id,
      notificationTimeSettings: state.notificationTimeSettings,
    );
    _saveSettings();
    ref.read(roomScheduleURLProvider.notifier).updateId(id);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', state.themeMode);
    await prefs.setString('language', state.language);
    if (state.classScheduleUrl != null) {
      await prefs.setString('classScheduleUrl', state.classScheduleUrl!);
    }
    if (state.roomScheduleId != null) {
      await prefs.setString('roomScheduleId', state.roomScheduleId!);
    }
    final settingsMap = state.notificationTimeSettings.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    await prefs.setString(
      'notificationTimeSettings',
      json.encode(state.notificationTimeSettings.map(
        (key, value) => MapEntry(key, value.toMap()),
      )),
    );
  }
}

final localSettingsProvider =
    StateNotifierProvider<LocalSettingsNotifier, LocalSettings>((ref) {
  return LocalSettingsNotifier(ref);
});
