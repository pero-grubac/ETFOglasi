import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSettings', () {
    test('copyWith keeps fields that are not changed', () {
      const settings = LocalSettings(
        classScheduleUrl: 'class',
        roomScheduleId: '42',
      );

      final updated = settings.copyWith(classScheduleUrl: 'other');

      expect(updated.classScheduleUrl, 'other');
      expect(updated.roomScheduleId, '42');
    });

    test('parses stored values with safe defaults', () {
      expect(LocalSettings.parseThemeMode('dark'), ThemeMode.dark);
      expect(LocalSettings.parseThemeMode('light'), ThemeMode.light);
      expect(LocalSettings.parseThemeMode(null), ThemeMode.system);
      expect(LocalSettings.parseThemeMode('garbage'), ThemeMode.system);
      for (final mode in ThemeMode.values) {
        expect(
          LocalSettings.parseThemeMode(LocalSettings.themeModeToString(mode)),
          mode,
        );
      }
      expect(LocalSettings.parseLanguage('sr-Cyrl'), LocalSettings.srCyrLang);
      expect(LocalSettings.parseLanguage('en'), LocalSettings.enLang);
      expect(LocalSettings.parseLanguage('de'), LocalSettings.srLatLang);
      expect(LocalSettings.parseLanguage(null), LocalSettings.srLatLang);
    });

    test('toLocale handles script subtags', () {
      final locale = LocalSettings.toLocale('sr-Cyrl');
      expect(locale.languageCode, 'sr');
      expect(locale.scriptCode, 'Cyrl');
      expect(LocalSettings.toLocale('sr').scriptCode, isNull);
    });
  });

  group('NotificationTimeSetting', () {
    test('encodeMap/decodeMap round trip', () {
      final settings = {
        'first_year': const NotificationTimeSetting(
          enabled: true,
          days: 1,
          hours: 2,
          minutes: 3,
        ),
        'second_year': NotificationTimeSetting.disabled,
      };

      final decoded = NotificationTimeSetting.decodeMap(
        NotificationTimeSetting.encodeMap(settings),
      );

      expect(decoded, settings);
    });

    test('decodeMap returns an empty map for missing or corrupt data', () {
      expect(NotificationTimeSetting.decodeMap(null), isEmpty);
      expect(NotificationTimeSetting.decodeMap('not json'), isEmpty);
      expect(NotificationTimeSetting.decodeMap('[1, 2]'), isEmpty);
    });

    test('totalMinutes', () {
      const setting = NotificationTimeSetting(
        enabled: true,
        days: 1,
        hours: 1,
        minutes: 1,
      );
      expect(setting.totalMinutes, 24 * 60 + 60 + 1);
    });
  });
}
