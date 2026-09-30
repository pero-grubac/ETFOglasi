import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseScheduleRows', () {
    test('maps Monday–Friday columns and ignores the weekend', () {
      final schedule = parseScheduleRows([
        ['9:15', 'A', 'B', 'C', 'D', 'E', 'SAT', 'SUN'],
      ]);

      expect(schedule.days.map((d) => d.single.subject), [
        'A',
        'B',
        'C',
        'D',
        'E',
      ]);
      expect(schedule.monday.single.time, '9:15');
    });

    test('skips malformed rows instead of throwing', () {
      final schedule = parseScheduleRows([
        null,
        [],
        ['9:15', 'A', 'B'], // too short
        [null, 'A', 'B', 'C', 'D', 'E'], // no time
        ['noon', 'A', 'B', 'C', 'D', 'E'], // bad time
        ['9:xx', 'A', 'B', 'C', 'D', 'E'], // bad minutes
        ['10:15', 'A', 'B', 'C', 'D', 'E'],
      ]);

      expect(schedule.monday.map((e) => e.time), ['10:15']);
    });

    test('keeps only hours between 8 and 22', () {
      final schedule = parseScheduleRows([
        for (var h = 0; h < 24; h++)
          ['$h:00', null, null, null, null, null, null, null],
      ]);

      expect(schedule.monday.first.time, '8:00');
      expect(schedule.monday.last.time, '21:00');
      expect(schedule.monday.length, 14);
    });

    test('sorts entries by time', () {
      final schedule = parseScheduleRows([
        ['12:15', 'C', null, null, null, null],
        ['8:15', 'A', null, null, null, null],
        ['10:15', 'B', null, null, null, null],
      ]);

      expect(schedule.monday.map((e) => e.subject), ['A', 'B', 'C']);
    });
  });

  group('cleanSubject', () {
    test('turns <br /> separators into new lines', () {
      expect(cleanSubject('A [1] <br /> --- <br /> B [2]'), 'A [1]\nB [2]');
      expect(cleanSubject('A<br>B<br/>C'), 'A\nB\nC');
    });

    test('decodes HTML entities', () {
      expect(cleanSubject('A &amp; B &quot;x&quot;'), 'A & B "x"');
    });

    test('returns null for non-strings and blank text', () {
      expect(cleanSubject(null), isNull);
      expect(cleanSubject(42), isNull);
      expect(cleanSubject('  '), isNull);
    });
  });

  group('Schedule.currentSlotIndex', () {
    final day = [
      ScheduleEntry(time: '8:15'),
      ScheduleEntry(time: '9:15'),
      ScheduleEntry(time: '10:15'),
    ];

    test('returns the slot that contains the time', () {
      expect(Schedule.currentSlotIndex(day, const Duration(hours: 9)), 0);
      expect(
        Schedule.currentSlotIndex(day, const Duration(hours: 9, minutes: 30)),
        1,
      );
    });

    test('clamps to the first and last slot', () {
      expect(Schedule.currentSlotIndex(day, const Duration(hours: 6)), 0);
      expect(Schedule.currentSlotIndex(day, const Duration(hours: 23)), 2);
    });

    test('returns null for an empty day', () {
      expect(Schedule.currentSlotIndex([], const Duration(hours: 9)), isNull);
    });
  });

  test('Schedule survives a toMap/fromMap round trip', () {
    final schedule = parseScheduleRows([
      ['8:15', 'A', 'B', null, 'D', 'E'],
    ]);
    final restored = Schedule.fromMap(schedule.toMap());

    expect(restored.days.map((d) => d.single.subject), [
      'A',
      'B',
      null,
      'D',
      'E',
    ]);
    expect(Schedule.empty().isEmpty, isTrue);
    expect(restored.isNotEmpty, isTrue);
  });
}
