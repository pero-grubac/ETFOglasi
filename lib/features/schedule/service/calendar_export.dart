import 'dart:convert';

import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';

/// Builds an iCalendar (.ics) file with one weekly repeating event per
/// class, from the first occurrence on or after [from] until [until]
/// (inclusive).
///
/// Times are "floating" (no time zone): calendars show them in the phone's
/// time zone, which is the faculty's for its students.
String buildScheduleCalendar({
  required List<ScheduleBlock> blocks,
  required DateTime from,
  required DateTime until,
  required DateTime now,
}) {
  final firstDay = DateTime(from.year, from.month, from.day);
  final untilEnd = DateTime(until.year, until.month, until.day, 23, 59, 59);
  final stamp = _formatUtc(now.toUtc());

  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//ETF Oglasi//Raspored//SR',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
  ];
  for (final block in blocks) {
    // Weekday of `firstDay` is 1 (Monday) … 7; block.day is 0 … 4.
    final offset = (block.day + 1 - firstDay.weekday) % 7;
    final date = DateTime(firstDay.year, firstDay.month, firstDay.day + offset);
    if (date.isAfter(untilEnd)) continue;

    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${_uid(block)}',
      'DTSTAMP:$stamp',
      'DTSTART:${_formatLocal(date.add(block.start))}',
      'DTEND:${_formatLocal(date.add(block.end))}',
      'RRULE:FREQ=WEEKLY;UNTIL=${_formatLocal(untilEnd)}',
      'SUMMARY:${_escape(block.title)}',
      if (block.room != null) 'LOCATION:${_escape(block.room!)}',
      if (block.subject.contains('\n')) 'DESCRIPTION:${_escape(block.subject)}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_fold).join('\r\n')}\r\n';
}

/// The last day of the current semester, as a default for [until]: the
/// winter semester runs to mid-January, the summer one to mid-June.
DateTime defaultSemesterEnd(DateTime now) {
  if (now.month >= 8) return DateTime(now.year + 1, 1, 20);
  if (now.month == 1) return DateTime(now.year, 1, 20);
  return DateTime(now.year, 6, 15);
}

/// Same class → same UID, so importing the file again updates the events
/// instead of duplicating them (in calendars that support it).
String _uid(ScheduleBlock block) {
  final key = '${block.day}|${block.start.inMinutes}|${block.subject}';
  // FNV-1a, 32 bits.
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  final time = block.start.inMinutes.toString().padLeft(4, '0');
  return 'd${block.day}t$time-${hash.toRadixString(16)}@etf-oglasi';
}

String _two(int value) => value.toString().padLeft(2, '0');

String _formatLocal(DateTime time) =>
    '${time.year}${_two(time.month)}${_two(time.day)}'
    'T${_two(time.hour)}${_two(time.minute)}${_two(time.second)}';

String _formatUtc(DateTime time) => '${_formatLocal(time)}Z';

String _escape(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\n', r'\n');

/// Lines longer than 75 bytes continue on the next line after a space
/// (RFC 5545). Splits on character boundaries, never inside a UTF-8 code
/// point.
String _fold(String line) {
  if (utf8.encode(line).length <= 75) return line;
  final parts = <String>[];
  final buffer = StringBuffer();
  var bytes = 0;
  var limit = 75;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    if (bytes + size > limit) {
      parts.add(buffer.toString());
      buffer.clear();
      bytes = 0;
      limit = 74; // Continuation lines start with a space.
    }
    buffer.write(char);
    bytes += size;
  }
  parts.add(buffer.toString());
  return parts.join('\r\n ');
}
