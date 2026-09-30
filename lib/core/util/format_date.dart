import 'package:intl/intl.dart';

/// Monday (at midnight) of the week containing [date].
DateTime getMondayOfWeek(DateTime date) {
  return DateTime(date.year, date.month, date.day - (date.weekday - 1));
}

/// Monday of the week to show by default: the current week on weekdays and
/// the next week on Saturday and Sunday.
DateTime defaultScheduleWeek(DateTime now) {
  final monday = getMondayOfWeek(now);
  return now.weekday > DateTime.friday ? addWeeks(monday, 1) : monday;
}

DateTime addWeeks(DateTime monday, int weeks) =>
    DateTime(monday.year, monday.month, monday.day + 7 * weeks);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

/// Range such as `28.09. – 02.10.2026` for the Monday–Friday week.
String formatWeekRange(DateTime monday) {
  final friday = DateTime(monday.year, monday.month, monday.day + 4);
  return '${DateFormat('dd.MM.').format(monday)} – '
      '${DateFormat('dd.MM.yyyy').format(friday)}';
}
