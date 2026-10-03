import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/announcements/service/announcements_provider.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationTimeSetting _every(int minutes) => NotificationTimeSetting(
  enabled: true,
  days: 0,
  hours: minutes ~/ 60,
  minutes: minutes % 60,
);

Announcement _announcement(int id, DateTime expires) => Announcement(
  id: id,
  naslov: 'Oglas $id',
  sadrzaj: '',
  vrijemeKreiranja: DateTime(2026),
  vrijemeIsteka: expires,
  oglasnaPloca: OglasnaPloca(id: 1),
  oglasPrilozi: const [],
);

void main() {
  final now = DateTime(2026, 10, 2, 12);

  group('checkFrequency', () {
    test('is the shortest enabled interval', () {
      expect(
        checkFrequency({
          'first_year': _every(60),
          'second_year': _every(30),
          'third_year': NotificationTimeSetting.disabled,
        }),
        const Duration(minutes: 30),
      );
    });

    test('is at least the WorkManager minimum', () {
      expect(
        checkFrequency({'first_year': _every(5)}),
        const Duration(minutes: NotificationTimeSetting.minMinutes),
      );
    });

    test('is null when nothing is enabled or the board is unknown', () {
      expect(checkFrequency({}), isNull);
      expect(
        checkFrequency({'first_year': NotificationTimeSetting.disabled}),
        isNull,
      );
      expect(checkFrequency({'no_such_board': _every(30)}), isNull);
    });
  });

  group('dueBoards', () {
    final settings = {
      'first_year': _every(15),
      'second_year': _every(60),
      'third_year': NotificationTimeSetting.disabled,
    };
    const frequency = Duration(minutes: 15);

    test('boards never checked are due', () {
      expect(
        dueBoards(
          settings: settings,
          lastChecks: {},
          now: now,
          frequency: frequency,
        ),
        ['first_year', 'second_year'],
      );
    });

    test('boards are due when their own interval has passed', () {
      final lastChecks = {
        'first_year': now.subtract(const Duration(minutes: 15)),
        'second_year': now.subtract(const Duration(minutes: 30)),
      };
      expect(
        dueBoards(
          settings: settings,
          lastChecks: lastChecks,
          now: now,
          frequency: frequency,
        ),
        ['first_year'],
      );
    });

    test('a run that comes a little early still counts', () {
      final lastChecks = {
        'first_year': now.subtract(const Duration(minutes: 14)),
        'second_year': now.subtract(const Duration(minutes: 55)),
      };
      expect(
        dueBoards(
          settings: settings,
          lastChecks: lastChecks,
          now: now,
          frequency: frequency,
        ),
        ['first_year', 'second_year'],
      );
    });

    test('but not one that is half a period early', () {
      final lastChecks = {
        'first_year': now.subtract(const Duration(minutes: 7)),
        'second_year': now.subtract(const Duration(minutes: 45)),
      };
      expect(
        dueBoards(
          settings: settings,
          lastChecks: lastChecks,
          now: now,
          frequency: frequency,
        ),
        isEmpty,
      );
    });
  });

  test('expired announcements are not notified', () {
    final result = notifiableAnnouncements([
      _announcement(1, now.add(const Duration(days: 1))),
      _announcement(2, now.subtract(const Duration(minutes: 1))),
    ], now);

    expect(result.map((a) => a.id), [1]);
  });

  test('expired announcements go last, keeping the API order', () {
    final active = now.add(const Duration(days: 1));
    final expired = now.subtract(const Duration(days: 1));
    final result = sortExpiredLast([
      _announcement(1, expired),
      _announcement(2, active),
      _announcement(3, expired),
      _announcement(4, active),
    ], now);

    expect(result.map((a) => a.id), [2, 4, 1, 3]);
  });

  test('last check times survive encoding and ignore bad data', () {
    final lastChecks = {'first_year': now};

    expect(decodeLastChecks(encodeLastChecks(lastChecks)), lastChecks);
    expect(decodeLastChecks(null), isEmpty);
    expect(decodeLastChecks('not json'), isEmpty);
    expect(decodeLastChecks('{"first_year": "x"}'), isEmpty);
  });
}
