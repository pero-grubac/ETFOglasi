import 'package:etf_oglasi/core/gen/app_localizations.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/navigation/notification_navigation.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:etf_oglasi/core/util/text_search.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/announcements/service/announcements_provider.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _latin = lookupAppLocalizations(
  const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
);

void main() {
  group('search', () {
    test('ignores case, diacritics and script', () {
      expect(normalizeForSearch('Čas ĐAK'), 'cas djak');
      expect(normalizeForSearch('Час Ђак'), 'cas djak');
      expect(matchesSearch('cas', ['Први ЧАС']), isTrue);
      expect(matchesSearch('ispit', ['Rezultati ispita']), isTrue);
    });

    test('requires every word and searches all fields', () {
      expect(
        matchesSearch('rezultati kolokvijum', ['Rezultati', 'kolokvijuma']),
        isTrue,
      );
      expect(matchesSearch('rezultati januar', ['Rezultati']), isFalse);
      expect(matchesSearch('  ', ['anything']), isTrue);
      expect(matchesSearch('x', [null]), isFalse);
    });
  });

  test('newAnnouncementIds', () {
    expect(newAnnouncementIds([1, 2, 3], {1, 3}), {2});
    expect(newAnnouncementIds([1, 2], null), isEmpty);
  });

  group('notification payload', () {
    test('maps board ids and old board URLs to categories', () {
      expect(
        categoryForNotificationPayload(_latin, '2')?.title,
        _latin.secondYear,
      );
      expect(
        categoryForNotificationPayload(_latin, '21')?.title,
        _latin.finalThesis,
      );
      final url = categoryForNotificationPayload(
        _latin,
        '3',
      )!.announcementsUrl!;
      expect(
        categoryForNotificationPayload(_latin, url)?.title,
        _latin.thirdYear,
      );
      expect(categoryForNotificationPayload(_latin, '999'), isNull);
    });

    test('every notification board exists on the home screen', () {
      for (final entry in notificationBoardIds.entries) {
        final category = categoryForNotificationPayload(_latin, entry.value);
        expect(category, isNotNull, reason: entry.key);
        expect(notificationBoardTitle(_latin, entry.key), category!.title);
      }
    });
  });

  group('weeks', () {
    test('default week is the next one on weekends', () {
      // 2026-10-01 is a Thursday, 2026-10-03 a Saturday.
      expect(defaultScheduleWeek(DateTime(2026, 10, 1)), DateTime(2026, 9, 28));
      expect(defaultScheduleWeek(DateTime(2026, 10, 3)), DateTime(2026, 10, 5));
      expect(defaultScheduleWeek(DateTime(2026, 10, 4)), DateTime(2026, 10, 5));
    });

    test('addWeeks and formatWeekRange', () {
      expect(addWeeks(DateTime(2026, 9, 28), -1), DateTime(2026, 9, 21));
      expect(formatWeekRange(DateTime(2026, 9, 28)), '28.09. – 02.10.2026');
      expect(isSameDay(DateTime(2026, 1, 1, 23), DateTime(2026, 1, 1)), isTrue);
    });
  });

  test('announcementShareText contains the important parts', () {
    final text = announcementShareText(
      Announcement(
        id: 1,
        naslov: 'Naslov',
        sadrzaj: 'Sadržaj',
        potpis: 'Prof. X',
        vrijemeKreiranja: DateTime(2026, 9, 1, 10),
        vrijemeIsteka: DateTime(2026, 10, 1),
        oglasnaPloca: OglasnaPloca(id: 1),
        oglasPrilozi: const [],
      ),
      _latin,
    );

    expect(text, startsWith('Naslov'));
    expect(text, contains('Sadržaj'));
    expect(text, contains('Potpis: Prof. X'));
    expect(text, contains('01.09.2026 10:00'));
  });
}
