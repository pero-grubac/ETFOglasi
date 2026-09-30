class ScheduleResult {
  /// Schedule URL (class schedule) or room id (room schedule).
  final String url;
  final bool isSave;

  /// Monday of the chosen week (room schedule "Select" only).
  final DateTime? week;

  ScheduleResult({required this.url, required this.isSave, this.week});
}
