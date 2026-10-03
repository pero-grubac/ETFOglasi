import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../gen/app_localizations.dart';

class NotificationService {
  static const String announcementChannelId = 'announcement_channel';
  static const String classReminderChannelId = 'class_reminder_channel';
  static const String _icon = '@drawable/ic_notification';

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Initializes the plugin and creates (or renames, when the language
  /// changes) the announcement channel. [onTap] receives the payload of a
  /// notification tapped while the app is running.
  Future<void> initialize(
    AppLocalizations locale, {
    void Function(String? payload)? onTap,
  }) async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: onTap != null
          ? (response) => onTap(response.payload)
          : null,
    );
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        announcementChannelId,
        locale.notificationChannelName,
        description: locale.notificationChannelDescription,
        importance: Importance.high,
      ),
    );
  }

  /// Payload of the notification that launched the app, if any.
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  Future<void> showNewAnnouncements({
    required int id,
    required String title,
    required List<String> announcementTitles,
    required AppLocalizations locale,
    String? payload,
  }) async {
    final body = announcementTitles.map((t) => '• $t').join('\n');
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        announcementChannelId,
        locale.notificationChannelName,
        channelDescription: locale.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _icon,
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
        showWhen: true,
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Cancels all scheduled class reminders.
  Future<void> cancelClassReminders() async {
    for (final request in await _plugin.pendingNotificationRequests()) {
      if (request.id >= classReminderIdBase) await _plugin.cancel(request.id);
    }
  }

  /// Schedules [reminders] to repeat every week. Uses exact alarms when the
  /// system allows them, otherwise Android may deliver them a few minutes
  /// late.
  Future<void> scheduleClassReminders(
    List<ClassReminder> reminders, {
    required AppLocalizations locale,
    required tz.Location location,
  }) async {
    if (reminders.isEmpty) return;
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        classReminderChannelId,
        locale.classReminderChannelName,
        description: locale.classReminderChannelDescription,
        importance: Importance.high,
      ),
    );
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        classReminderChannelId,
        locale.classReminderChannelName,
        channelDescription: locale.classReminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _icon,
        category: AndroidNotificationCategory.reminder,
      ),
    );
    final now = tz.TZDateTime.now(location);
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        nextWeeklyInstance(now, reminder.weekday, reminder.time),
        details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: classSchedulePayload,
      );
    }
  }
}
