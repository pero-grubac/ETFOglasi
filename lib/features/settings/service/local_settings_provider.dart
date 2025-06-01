import 'package:etf_oglasi/core/service/provider/class_schedule_url_notifier.dart';
import 'package:etf_oglasi/core/service/provider/locale_notifier.dart';
import 'package:etf_oglasi/core/service/provider/room_schedule_url_notifier.dart';
import 'package:etf_oglasi/core/service/provider/theme_notifier.dart';
import 'package:etf_oglasi/features/settings/data/model/local_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsNotifier extends StateNotifier<LocalSettings> {
  final Ref ref;
  LocalSettingsNotifier(this.ref)
      : super(LocalSettings(
          language: LocalSettings.srLatLang,
          themeMode: LocalSettings.darkMode,
        )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode') ?? LocalSettings.lightMode;
    final language = prefs.getString('language') ?? LocalSettings.srLatLang;
    final String? classScheduleUrl = prefs.getString('classScheduleUrl');
    final String? roomScheduleId = prefs.getString('roomScheduleId');
    state = LocalSettings(
      themeMode: themeMode,
      language: language,
      classScheduleUrl: classScheduleUrl,
      roomScheduleId: roomScheduleId,
    );

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
    );
    _saveSettings();

    final locale = parseLocale(language);
    ref.read(localeProvider.notifier).updateLocale(locale);
  }

  void updateClassScheduleURL(String url) {
    state = LocalSettings(
      language: state.language,
      themeMode: state.themeMode,
      classScheduleUrl: url,
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
  }
}

final localSettingsProvider =
    StateNotifierProvider<LocalSettingsNotifier, LocalSettings>((ref) {
  return LocalSettingsNotifier(ref);
});
