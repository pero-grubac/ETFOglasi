import 'package:etf_oglasi/features/schedule/model/schedule.dart';

/// One class: consecutive slots with the same subject merged together.
class ScheduleBlock {
  /// Day of the week, 0 = Monday … 4 = Friday.
  final int day;
  final Duration start;
  final Duration end;
  final String subject;

  const ScheduleBlock({
    required this.day,
    required this.start,
    required this.end,
    required this.subject,
  });

  /// The room in square brackets at the end, e.g. `1103` from
  /// `Električna mjerenja (svi) [1103]`. `null` for several groups in
  /// different rooms (multi-line subjects).
  String? get room {
    if (subject.contains('\n')) return null;
    return RegExp(r'\[([^\]]+)\]\s*$').firstMatch(subject)?.group(1);
  }

  /// The subject without the room, e.g. `Električna mjerenja (svi)`.
  String get title {
    if (subject.contains('\n')) return subject;
    return subject.replaceFirst(RegExp(r'\s*\[[^\]]+\]\s*$'), '');
  }

  @override
  bool operator ==(Object other) =>
      other is ScheduleBlock &&
      other.day == day &&
      other.start == start &&
      other.end == end &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(day, start, end, subject);

  @override
  String toString() =>
      'ScheduleBlock($day, ${formatDuration(start)}–${formatDuration(end)}, '
      '$subject)';
}

/// A slot starts at :15 and lasts 45 minutes (8:15–9:00, 9:15–10:00, …).
const Duration slotLength = Duration(minutes: 45);

/// The classes of one sorted day. A subject spanning several consecutive
/// slots becomes one block that ends 45 minutes after its last slot starts.
List<ScheduleBlock> dayBlocks(int day, List<ScheduleEntry> entries) {
  final blocks = <ScheduleBlock>[];
  String? subject;
  Duration? start;
  Duration? lastSlot;

  void close() {
    if (subject != null) {
      blocks.add(
        ScheduleBlock(
          day: day,
          start: start!,
          end: lastSlot! + slotLength,
          subject: subject!,
        ),
      );
    }
    subject = null;
  }

  final sorted = [...entries]
    ..sort(
      (a, b) =>
          Schedule.parseTime(a.time).compareTo(Schedule.parseTime(b.time)),
    );
  for (final entry in sorted) {
    final time = Schedule.parseTime(entry.time);
    final current = entry.subject;
    final continues =
        current != null &&
        current == subject &&
        lastSlot != null &&
        time - lastSlot <= const Duration(hours: 1);
    if (continues) {
      lastSlot = time;
      continue;
    }
    close();
    if (current != null) {
      subject = current;
      start = time;
      lastSlot = time;
    }
  }
  close();
  return blocks;
}

/// All classes of the week, Monday first.
List<ScheduleBlock> scheduleBlocks(Schedule schedule) => [
  for (var day = 0; day < schedule.days.length; day++)
    ...dayBlocks(day, schedule.days[day]),
];

/// `9:15`, `11:00`.
String formatDuration(Duration time) {
  final minutes = time.inMinutes;
  return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
}
