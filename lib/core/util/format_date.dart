import 'package:intl/intl.dart';

DateTime getMondayOfWeek(DateTime date) {
  final int dayOfWeek = date.weekday;
  final int daysToSubtract = dayOfWeek - 1;
  return date.subtract(Duration(days: daysToSubtract));
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
