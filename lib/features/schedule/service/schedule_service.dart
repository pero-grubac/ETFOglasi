import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';

class ScheduleService {
  final ApiService service;

  ScheduleService({required this.service});

  Future<Schedule> fetchSchedule(String url) {
    return service.fetchData<Schedule>(
      url: url,
      fromJson: (json) => parseScheduleRows(json as List<dynamic>),
    );
  }
}

// Endpoints may return all 24 hours (e.g. room schedule by date); only the
// teaching hours are shown.
const int _firstHour = 8;
const int _lastHourExclusive = 22;

final RegExp _separator = RegExp(r'\s*<br\s*/?>\s*(?:---\s*<br\s*/?>\s*)?');
const Map<String, String> _entities = {
  '&nbsp;': ' ',
  '&quot;': '"',
  '&#39;': "'",
  '&lt;': '<',
  '&gt;': '>',
  '&amp;': '&', // must be last
};

String? cleanSubject(dynamic subject) {
  if (subject is! String) return null;
  var text = subject.replaceAll(_separator, '\n');
  _entities.forEach((entity, value) => text = text.replaceAll(entity, value));
  text = text.trim();
  return text.isEmpty ? null : text;
}

/// Converts API rows `[time, mon, tue, wed, thu, fri, sat, sun]` into a
/// Monday–Friday [Schedule]. Malformed rows are skipped.
Schedule parseScheduleRows(List<dynamic> rows) {
  final schedule = Schedule.empty();

  for (final row in rows) {
    if (row is! List || row.length < 6) continue;

    final time = row[0];
    if (time is! String) continue;
    final timeParts = time.split(':');
    if (timeParts.length != 2) continue;
    final hour = int.tryParse(timeParts[0]);
    if (hour == null || int.tryParse(timeParts[1]) == null) continue;
    if (hour < _firstHour || hour >= _lastHourExclusive) continue;

    for (var day = 0; day < 5; day++) {
      schedule.days[day].add(
        ScheduleEntry(time: time, subject: cleanSubject(row[day + 1])),
      );
    }
  }

  schedule.sort();
  return schedule;
}
