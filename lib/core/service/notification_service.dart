import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../gen/app_localizations.dart';

class NotificationService {
  static const String announcementChannelId = 'announcement_channel';
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
}
