class Schedule {
  final List<(String, String?)> monday;
  final List<(String, String?)> tuesday;
  final List<(String, String?)> wednesday;
  final List<(String, String?)> thursday;
  final List<(String, String?)> friday;

  Schedule({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
  });

  void sort() {
    monday.sort((a, b) => parseTime(a.$1).compareTo(parseTime(b.$1)));
    tuesday.sort((a, b) => parseTime(a.$1).compareTo(parseTime(b.$1)));
    wednesday.sort((a, b) => parseTime(a.$1).compareTo(parseTime(b.$1)));
    thursday.sort((a, b) => parseTime(a.$1).compareTo(parseTime(b.$1)));
    friday.sort((a, b) => parseTime(a.$1).compareTo(parseTime(b.$1)));
  }

  Duration parseTime(String time) {
    final parts = time.split(":");
    final hours = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    return Duration(hours: hours, minutes: min);
  }
}
