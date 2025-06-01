import 'dart:convert';

import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';

class LocalSettings {
  static const darkMode = 'dark';
  static const lightMode = 'light';

  static const srLatLang = 'sr-Latn';
  static const srLatName = 'Latinica';

  static const srCyrLang = 'sr-Cyrl';
  static const srCyrName = 'Ћирилица';

  final String language;
  final String themeMode;
  final String? classScheduleUrl;
  final String? roomScheduleId;
  final Map<String, NotificationTimeSetting> notificationTimeSettings;
  LocalSettings({
    required this.language,
    required this.themeMode,
    this.classScheduleUrl,
    this.roomScheduleId,
    required this.notificationTimeSettings,
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'themeMode': themeMode,
      'classScheduleUrl': classScheduleUrl,
      'roomScheduleId': roomScheduleId,
      'notificationTimeSettings': notificationTimeSettings.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  factory LocalSettings.fromMap(Map<String, dynamic> map) {
    final themeMode = map['themeMode'] as String? ?? lightMode;
    final language = map['language'] as String? ?? srLatLang;
    final classScheduleUrl = map['classScheduleUrl'] as String?;
    final roomScheduleId = map['roomScheduleId'] as String?;
    final notificationTimeSettings = <String, NotificationTimeSetting>{};
    if (map['notificationTimeSettings'] is Map<String, dynamic>) {
      (map['notificationTimeSettings'] as Map<String, dynamic>)
          .forEach((key, value) {
        if (value is Map<String, dynamic>) {
          notificationTimeSettings[key] =
              NotificationTimeSetting.fromMap(value);
        }
      });
    }
    return LocalSettings(
      themeMode: themeMode == darkMode ? darkMode : lightMode,
      language: language == srCyrLang ? srCyrLang : srLatLang,
      classScheduleUrl: classScheduleUrl,
      roomScheduleId: roomScheduleId,
      notificationTimeSettings: notificationTimeSettings,
    );
  }
  String toJson() => json.encode(toMap());
  factory LocalSettings.fromJson(String source) =>
      LocalSettings.fromMap(json.decode(source));
}
