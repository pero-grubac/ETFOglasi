import 'dart:convert';

class NotificationTimeSetting {
  static const int minMinutes = 15;

  final bool enabled;
  final int days;
  final int hours;
  final int minutes;

  const NotificationTimeSetting({
    required this.enabled,
    required this.days,
    required this.hours,
    required this.minutes,
  });

  static const disabled = NotificationTimeSetting(
    enabled: false,
    days: 0,
    hours: 0,
    minutes: 0,
  );

  int get totalMinutes => days * 24 * 60 + hours * 60 + minutes;

  NotificationTimeSetting copyWith({
    bool? enabled,
    int? days,
    int? hours,
    int? minutes,
  }) {
    return NotificationTimeSetting(
      enabled: enabled ?? this.enabled,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
    );
  }

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

  @override
  bool operator ==(Object other) =>
      other is NotificationTimeSetting &&
      other.enabled == enabled &&
      other.days == days &&
      other.hours == hours &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(enabled, days, hours, minutes);

  static String encodeMap(Map<String, NotificationTimeSetting> settings) =>
      json.encode(settings.map((key, value) => MapEntry(key, value.toMap())));

  /// Decodes the stored settings map; returns an empty map for missing or
  /// corrupt data instead of throwing.
  static Map<String, NotificationTimeSetting> decodeMap(String? source) {
    if (source == null) return {};
    try {
      final decoded = json.decode(source);
      if (decoded is! Map<String, dynamic>) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.value is Map<String, dynamic>)
            entry.key: NotificationTimeSetting.fromMap(entry.value),
      };
    } catch (_) {
      return {};
    }
  }
}
