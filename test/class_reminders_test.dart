import 'package:etf_oglasi/core/gen/app_localizations.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

Duration _t(int hours, int minutes) => Duration(hours: hours, minutes: minutes);

void main() {
  final locale = lookupAppLocalizations(
    const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
  );
  final location = facultyTimeZone();

  test('one reminder per class, before it starts', () {
    final reminders = buildClassReminders(
      [
        ScheduleBlock(
          day: 0,
          start: _t(9, 15),
          end: _t(11, 0),
          subject: 'Mjerenja (svi) [1103]',
        ),
        ScheduleBlock(
          day: 3,
          start: _t(16, 15),
          end: _t(18, 0),
          subject: 'PJ1 (G1) [1110]\nPJ1 (G2) [1101]',
        ),
      ],
      10,
      locale,
    );

    expect(reminders, hasLength(2));
    expect(reminders[0].id, classReminderIdBase);
    expect(reminders[0].weekday, DateTime.monday);
    expect(reminders[0].time, _t(9, 5));
    expect(reminders[0].title, 'Za 10 min: Mjerenja (svi)');
    expect(reminders[0].body, '9:15–11:00 · 1103');

    expect(reminders[1].weekday, DateTime.thursday);
    expect(reminders[1].body, '16:15–18:00 · PJ1 (G1) [1110]\nPJ1 (G2) [1101]');
  });

  group('nextWeeklyInstance', () {
    test('later the same day', () {
      // Monday 5 October 2026, 8:00.
      final now = tz.TZDateTime(location, 2026, 10, 5, 8);
      final next = nextWeeklyInstance(now, DateTime.monday, _t(9, 5));

      expect(next, tz.TZDateTime(location, 2026, 10, 5, 9, 5));
    });

    test('already passed today: next week', () {
      final now = tz.TZDateTime(location, 2026, 10, 5, 10);
      final next = nextWeeklyInstance(now, DateTime.monday, _t(9, 5));

      expect(next, tz.TZDateTime(location, 2026, 10, 12, 9, 5));
    });

    test('a later weekday', () {
      final now = tz.TZDateTime(location, 2026, 10, 5, 10);
      final next = nextWeeklyInstance(now, DateTime.thursday, _t(16, 5));

      expect(next, tz.TZDateTime(location, 2026, 10, 8, 16, 5));
    });

    test('keeps the time across the switch to winter time', () {
      // Clocks go back on Sunday 25 October 2026.
      final now = tz.TZDateTime(location, 2026, 10, 23, 12);
      final next = nextWeeklyInstance(now, DateTime.monday, _t(9, 5));

      expect(next.day, 26);
      expect(next.hour, 9);
      expect(next.minute, 5);
    });
  });
}
