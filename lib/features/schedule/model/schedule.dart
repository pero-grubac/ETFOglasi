import 'dart:convert';

class ScheduleEntry {
  final String time;
  final String? subject;

  ScheduleEntry({required this.time, this.subject});

  Map<String, dynamic> toMap() {
    return {'time': time, 'subject': subject};
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
  static const List<String> _dayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

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

  Schedule.empty()
    : monday = [],
      tuesday = [],
      wednesday = [],
      thursday = [],
      friday = [];

  /// Monday to Friday, in order.
  List<List<ScheduleEntry>> get days => [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
  ];

  bool get isEmpty => days.every((day) => day.isEmpty);

  bool get isNotEmpty => !isEmpty;

  void sort() {
    for (final day in days) {
      day.sort((a, b) => parseTime(a.time).compareTo(parseTime(b.time)));
    }
  }

  static Duration parseTime(String time) {
    final parts = time.split(":");
    final hours = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    return Duration(hours: hours, minutes: min);
  }

  /// Index of the slot that contains [now] in a sorted [day]: the first slot
  /// before classes start, the last slot after they end, or `null` when the
  /// day is empty.
  static int? currentSlotIndex(List<ScheduleEntry> day, Duration now) {
    if (day.isEmpty) return null;
    var index = 0;
    for (var i = 0; i < day.length; i++) {
      if (parseTime(day[i].time) <= now) index = i;
    }
    return index;
  }

  Map<String, dynamic> toMap() {
    return {
      'data': jsonEncode({
        for (var i = 0; i < _dayKeys.length; i++)
          _dayKeys[i]: days[i].map((e) => e.toMap()).toList(),
      }),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    final data = jsonDecode(map['data'] as String) as Map<String, dynamic>;
    List<ScheduleEntry> day(String key) => (data[key] as List<dynamic>)
        .map((e) => ScheduleEntry.fromMap(e as Map<String, dynamic>))
        .toList();
    return Schedule(
      monday: day('monday'),
      tuesday: day('tuesday'),
      wednesday: day('wednesday'),
      thursday: day('thursday'),
      friday: day('friday'),
    );
  }
}
