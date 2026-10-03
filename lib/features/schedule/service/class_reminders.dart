import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/gen/app_localizations.dart';

/// Payload of reminder notifications: tapping one opens the class schedule.
const classSchedulePayload = 'class_schedule';

/// Minutes-before options offered in the settings; 0 turns reminders off.
const classReminderOptions = [5, 10, 15, 30];

/// A weekly notification before one class.
class ClassReminder {
  final int id;

  /// 1 = Monday … 5 = Friday ([DateTime.weekday]).
  final int weekday;

  /// Time of day of the notification.
  final Duration time;
  final String title;
  final String body;

  const ClassReminder({
    required this.id,
    required this.weekday,
    required this.time,
    required this.title,
    required this.body,
  });
}

/// Notification ids of class reminders start here, away from the board ids
/// used by announcement notifications.
const classReminderIdBase = 100000;

/// One reminder per class, [minutesBefore] minutes before it starts.
List<ClassReminder> buildClassReminders(
  List<ScheduleBlock> blocks,
  int minutesBefore,
  AppLocalizations locale,
) {
  return [
    for (var i = 0; i < blocks.length; i++)
      ClassReminder(
        id: classReminderIdBase + i,
        weekday: blocks[i].day + 1,
        time: blocks[i].start - Duration(minutes: minutesBefore),
        title: locale.classReminderTitle(
          minutes: minutesBefore,
          subject: blocks[i].title,
        ),
        body: [
          '${formatDuration(blocks[i].start)}–${formatDuration(blocks[i].end)}',
          ?blocks[i].room,
          if (blocks[i].subject.contains('\n')) blocks[i].subject,
        ].join(' · '),
      ),
  ];
}

/// The next time on or after [now] that falls on [weekday] at [time].
tz.TZDateTime nextWeeklyInstance(
  tz.TZDateTime now,
  int weekday,
  Duration time,
) {
  var candidate = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    time.inHours,
    time.inMinutes % 60,
  );
  while (candidate.weekday != weekday || candidate.isBefore(now)) {
    final next = candidate.add(const Duration(days: 1));
    // Rebuild from the date so a DST change doesn't shift the time.
    candidate = tz.TZDateTime(
      now.location,
      next.year,
      next.month,
      next.day,
      time.inHours,
      time.inMinutes % 60,
    );
  }
  return candidate;
}

bool _timeZonesLoaded = false;

/// Classes are in Banja Luka, so reminders use its time zone whatever the
/// phone is set to.
tz.Location facultyTimeZone() {
  if (!_timeZonesLoaded) {
    tz_data.initializeTimeZones();
    _timeZonesLoaded = true;
  }
  return tz.getLocation('Europe/Sarajevo');
}
