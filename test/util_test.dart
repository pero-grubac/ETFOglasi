import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getMondayOfWeek', () {
    test('returns the Monday of the same week at midnight', () {
      // 2026-10-01 is a Thursday.
      expect(
        getMondayOfWeek(DateTime(2026, 10, 1, 15, 30)),
        DateTime(2026, 9, 28),
      );
      expect(getMondayOfWeek(DateTime(2026, 9, 28)), DateTime(2026, 9, 28));
      // Sunday belongs to the week that started six days earlier.
      expect(getMondayOfWeek(DateTime(2026, 10, 4)), DateTime(2026, 9, 28));
    });

    test('works across a month boundary', () {
      expect(getMondayOfWeek(DateTime(2026, 3, 1)), DateTime(2026, 2, 23));
    });
  });

  test('formatDate uses yyyy-MM-dd', () {
    expect(formatDate(DateTime(2026, 9, 7)), '2026-09-07');
  });

  test('URL builders', () {
    const base = 'https://efee.etf.unibl.org:8443/api/public/';
    expect(getAnnouncementsUrl('3'), '${base}oglasne-ploce/3');
    expect(getAnnouncementDownloadUrl('12'), '${base}oglasi/12/download');
    expect(
      getScheduleUrl('5', '7'),
      '${base}raspored/studijski-program/5/godina/7',
    );
    expect(
      getRoomScheduleUrl('9', '2026-09-28'),
      '${base}raspored/9/2026-09-28',
    );
    expect(getScheduleByTeacherUrl('4'), '${base}raspored/po-nastavniku/4');
    expect(getScheduleByRoomUrl('4'), '${base}raspored/po-prostoriji/4');
  });
}
