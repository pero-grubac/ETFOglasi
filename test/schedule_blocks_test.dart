import 'dart:convert';

import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:etf_oglasi/features/schedule/service/calendar_export.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_widget.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduleEntry _slot(String time, [String? subject]) =>
    ScheduleEntry(time: time, subject: subject);

Duration _t(int hours, int minutes) => Duration(hours: hours, minutes: minutes);

void main() {
  group('dayBlocks', () {
    test('merges consecutive slots with the same subject', () {
      final blocks = dayBlocks(0, [
        _slot('8:15'),
        _slot('9:15', 'Mjerenja (svi) [1103]'),
        _slot('10:15', 'Mjerenja (svi) [1103]'),
        _slot('11:15', 'Kola (svi) [1104]'),
        _slot('12:15'),
        _slot('13:15', 'Kola (svi) [1104]'),
      ]);

      expect(blocks, [
        ScheduleBlock(
          day: 0,
          start: _t(9, 15),
          end: _t(11, 0),
          subject: 'Mjerenja (svi) [1103]',
        ),
        ScheduleBlock(
          day: 0,
          start: _t(11, 15),
          end: _t(12, 0),
          subject: 'Kola (svi) [1104]',
        ),
        // Same subject after a free slot is a separate class.
        ScheduleBlock(
          day: 0,
          start: _t(13, 15),
          end: _t(14, 0),
          subject: 'Kola (svi) [1104]',
        ),
      ]);
    });

    test('sorts the slots first', () {
      final blocks = dayBlocks(2, [
        _slot('10:15', 'A [1]'),
        _slot('9:15', 'A [1]'),
      ]);

      expect(blocks.single.start, _t(9, 15));
      expect(blocks.single.end, _t(11, 0));
    });

    test('an empty day has no blocks', () {
      expect(dayBlocks(0, [_slot('8:15'), _slot('9:15')]), isEmpty);
      expect(dayBlocks(0, []), isEmpty);
    });
  });

  test('splits the room from the title', () {
    const block = ScheduleBlock(
      day: 0,
      start: Duration.zero,
      end: Duration.zero,
      subject: 'Uvod u elektroniku (svi) [1203 (LAK)]',
    );
    expect(block.room, '1203 (LAK)');
    expect(block.title, 'Uvod u elektroniku (svi)');

    const groups = ScheduleBlock(
      day: 0,
      start: Duration.zero,
      end: Duration.zero,
      subject: 'PJ1 (G1) [1110]\nPJ1 (G2) [1101]',
    );
    expect(groups.room, isNull);
    expect(groups.title, groups.subject);
  });

  test('widget text has one line per class', () {
    final text = widgetDayText([
      ScheduleBlock(
        day: 0,
        start: _t(9, 15),
        end: _t(11, 0),
        subject: 'Mjerenja (svi) [1103]',
      ),
      ScheduleBlock(
        day: 0,
        start: _t(16, 15),
        end: _t(18, 0),
        subject: 'PJ1 (G1) [1110]\nPJ1 (G2) [1101]',
      ),
    ]);

    expect(
      text,
      '9:15–11:00  Mjerenja (svi) · 1103\n'
      '16:15–18:00  PJ1 (G1) [1110] / PJ1 (G2) [1101]',
    );
    expect(widgetDayText([]), isEmpty);
  });

  test('next-class widget data is JSON with minutes', () {
    final json = widgetDayJson([
      ScheduleBlock(
        day: 0,
        start: _t(9, 15),
        end: _t(11, 0),
        subject: 'Mjerenja (svi) [1103]',
      ),
      ScheduleBlock(
        day: 0,
        start: _t(16, 15),
        end: _t(18, 0),
        subject: 'PJ1 (G1) [1110]\nPJ1 (G2) [1101]',
      ),
    ]);

    expect(jsonDecode(json), [
      {'s': 555, 'e': 660, 't': 'Mjerenja (svi)', 'r': '1103'},
      {
        's': 975,
        'e': 1080,
        't': 'PJ1 (G1) [1110] / PJ1 (G2) [1101]',
        'r': null,
      },
    ]);
    expect(widgetDayJson([]), '[]');
  });

  test('formatDuration', () {
    expect(formatDuration(_t(9, 15)), '9:15');
    expect(formatDuration(_t(11, 0)), '11:00');
  });

  group('buildScheduleCalendar', () {
    // Saturday, 3 October 2026.
    final now = DateTime(2026, 10, 3, 12);
    final blocks = [
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
    ];

    String build({DateTime? until}) => buildScheduleCalendar(
      blocks: blocks,
      from: now,
      until: until ?? DateTime(2027, 1, 20),
      now: now,
    );

    test('creates a weekly event per class from the next occurrence', () {
      final ics = build();
      final lines = ics.split('\r\n');

      expect(lines.first, 'BEGIN:VCALENDAR');
      expect(ics, endsWith('END:VCALENDAR\r\n'));
      expect('BEGIN:VEVENT'.allMatches(ics), hasLength(2));
      // Monday 5 October and Thursday 8 October.
      expect(lines, contains('DTSTART:20261005T091500'));
      expect(lines, contains('DTEND:20261005T110000'));
      expect(lines, contains('DTSTART:20261008T161500'));
      expect(lines, contains('RRULE:FREQ=WEEKLY;UNTIL=20270120T235959'));
      expect(lines, contains('SUMMARY:Mjerenja (svi)'));
      expect(lines, contains('LOCATION:1103'));
    });

    test('escapes text and keeps several groups in the description', () {
      final ics = build();

      expect(ics, contains(r'DESCRIPTION:PJ1 (G1) [1110]\nPJ1 (G2) [1101]'));
    });

    test('leaves out classes that start after the end date', () {
      // Until Wednesday: only Monday's class fits.
      final ics = build(until: DateTime(2026, 10, 7));

      expect('BEGIN:VEVENT'.allMatches(ics), hasLength(1));
    });

    test('folds long lines without splitting characters', () {
      final long = ScheduleBlock(
        day: 1,
        start: _t(8, 15),
        end: _t(9, 0),
        subject: '${'Структуре података и алгоритми ' * 4}[1101]',
      );
      final ics = buildScheduleCalendar(
        blocks: [long],
        from: now,
        until: DateTime(2027),
        now: now,
      );

      for (final line in ics.split('\r\n')) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75));
      }
      final summary = ics
          .split('\r\n')
          .skipWhile((l) => !l.startsWith('SUMMARY:'))
          .takeWhile((l) => l.startsWith('SUMMARY:') || l.startsWith(' '))
          .toList();
      expect(summary.length, greaterThan(1));
      // Unfolding gives the original text back.
      expect(
        summary.map((l) => l.startsWith(' ') ? l.substring(1) : l).join(),
        'SUMMARY:${long.title}',
      );
    });
  });

  test('defaultSemesterEnd', () {
    expect(defaultSemesterEnd(DateTime(2026, 10, 3)), DateTime(2027, 1, 20));
    expect(defaultSemesterEnd(DateTime(2027, 1, 10)), DateTime(2027, 1, 20));
    expect(defaultSemesterEnd(DateTime(2027, 3, 1)), DateTime(2027, 6, 15));
  });
}
