import 'dart:convert';

class ScheduleEntry {
  final String time;
  final String? subject;

  ScheduleEntry({required this.time, this.subject});

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'subject': subject,
    };
  }

  factory ScheduleEntry.fromMap(Map<String, dynamic> map) {
    return ScheduleEntry(
      time: map['time'] as String,
      subject: map['subject'] as String?,
    );
  }
}

class Schedule {
  static const String dbName = 'schedule';
  final List<ScheduleEntry> monday;
  final List<ScheduleEntry> tuesday;
  final List<ScheduleEntry> wednesday;
  final List<ScheduleEntry> thursday;
  final List<ScheduleEntry> friday;

  Schedule({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
  });

  void sort() {
    for (var day in [monday, tuesday, wednesday, thursday, friday]) {
      day.sort((a, b) => parseTime(a.time).compareTo(parseTime(b.time)));
    }
  }

  Duration parseTime(String time) {
    final parts = time.split(":");
    final hours = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    return Duration(hours: hours, minutes: min);
  }

  Map<String, dynamic> toMap() {
    return {
      'data': jsonEncode({
        'monday': monday.map((e) => e.toMap()).toList(),
        'tuesday': tuesday.map((e) => e.toMap()).toList(),
        'wednesday': wednesday.map((e) => e.toMap()).toList(),
        'thursday': thursday.map((e) => e.toMap()).toList(),
        'friday': friday.map((e) => e.toMap()).toList(),
      }),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    final data = jsonDecode(map['data'] as String) as Map<String, dynamic>;
    return Schedule(
      monday: (data['monday'] as List<dynamic>)
          .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      tuesday: (data['tuesday'] as List<dynamic>)
          .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      wednesday: (data['wednesday'] as List<dynamic>)
          .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      thursday: (data['thursday'] as List<dynamic>)
          .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      friday: (data['friday'] as List<dynamic>)
          .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
