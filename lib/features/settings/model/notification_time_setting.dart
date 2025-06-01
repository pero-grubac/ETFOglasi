class NotificationTimeSetting {
  final bool enabled;
  final int days;
  final int hours;
  final int minutes;

  NotificationTimeSetting({
    required this.enabled,
    required this.days,
    required this.hours,
    required this.minutes,
  });
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'days': days,
      'hours': hours,
      'minutes': minutes,
    };
  }

  factory NotificationTimeSetting.fromMap(Map<String, dynamic> map) {
    return NotificationTimeSetting(
      enabled: map['enabled'] ?? false,
      days: map['days'] ?? 0,
      hours: map['hours'] ?? 0,
      minutes: map['minutes'] ?? 0,
    );
  }
}
