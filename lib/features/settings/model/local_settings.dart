import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:flutter/material.dart';

class LocalSettings {
  static const darkMode = 'dark';
  static const lightMode = 'light';
  static const systemMode = 'system';

  static const srLatLang = 'sr-Latn';
  static const srLatName = 'Latinica';

  static const srCyrLang = 'sr-Cyrl';
  static const srCyrName = 'Ћирилица';

  // SharedPreferences keys (also read by the background worker).
  static const themeModeKey = 'themeMode';
  static const languageKey = 'language';
  static const classScheduleUrlKey = 'classScheduleUrl';
  static const roomScheduleIdKey = 'roomScheduleId';
  static const notificationTimeSettingsKey = 'notificationTimeSettings';

  final String language;
  final ThemeMode themeMode;
  final String? classScheduleUrl;
  final String? roomScheduleId;
  final Map<String, NotificationTimeSetting> notificationTimeSettings;

  const LocalSettings({
    this.language = srLatLang,
    this.themeMode = ThemeMode.system,
    this.classScheduleUrl,
    this.roomScheduleId,
    this.notificationTimeSettings = const {},
  });

  LocalSettings copyWith({
    String? language,
    ThemeMode? themeMode,
    String? classScheduleUrl,
    String? roomScheduleId,
    Map<String, NotificationTimeSetting>? notificationTimeSettings,
  }) {
    return LocalSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      classScheduleUrl: classScheduleUrl ?? this.classScheduleUrl,
      roomScheduleId: roomScheduleId ?? this.roomScheduleId,
      notificationTimeSettings:
          notificationTimeSettings ?? this.notificationTimeSettings,
    );
  }

  static ThemeMode parseThemeMode(String? value) => switch (value) {
    darkMode => ThemeMode.dark,
    lightMode => ThemeMode.light,
    _ => ThemeMode.system,
  };

  static String themeModeToString(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => darkMode,
    ThemeMode.light => lightMode,
    ThemeMode.system => systemMode,
  };

  static String parseLanguage(String? value) =>
      value == srCyrLang ? srCyrLang : srLatLang;

  /// Converts a language tag such as `sr-Latn` to a [Locale].
  static Locale toLocale(String language) {
    final parts = language.split('-');
    if (parts.length == 2) {
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(language);
  }
}
