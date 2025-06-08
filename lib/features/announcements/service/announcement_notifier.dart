import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _showNewAnnouncementsNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required String url,
  required String title,
  required String body,
}) async {
  final BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(
    body,
    contentTitle: title,
    summaryText: null,
  );
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'announcement_channel',
    'Announcements',
    channelDescription: 'Channel for announcement notifications',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: bigTextStyleInformation,
    showWhen: true,
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await notificationsPlugin.show(
    url.hashCode,
    title,
    body,
    platformChannelSpecifics,
    payload: url,
  );
}

Future<void> fetchAndCompareAnnouncements({
  required String url,
  required AnnouncementService service,
  required AnnouncementRepository repository,
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required String language,
}) async {
  final List<Announcement> apiAnnouncements =
      await service.fetchAnnouncements(url);
  if (apiAnnouncements.isEmpty) {
    return;
  }

  final List<Announcement>? dbAnnouncements =
      await repository.findAnnouncementsById(url);
  final Set<int> dbIds = dbAnnouncements?.map((a) => a.id).toSet() ?? {};

  final List<Announcement> newAnnouncements =
      apiAnnouncements; //  apiAnnouncements.where((a) => !dbIds.contains(a.id)).toList();

  if (newAnnouncements.isNotEmpty) {
    final String appTitle = getLocalizedAppTitle(language);
    final String body = formatAnnouncementsBody(newAnnouncements);

    await _showNewAnnouncementsNotification(
      notificationsPlugin: notificationsPlugin,
      url: url,
      title: appTitle,
      body: body,
    );
  }

  // Save new list to DB (overwrite)
  // await repository.saveAnnouncements(url, apiAnnouncements);
}

String getLocalizedAppTitle(String language) {
  if (language == LocalSettings.srCyrLang) {
    return 'ЕТФ';
  } else if (language == LocalSettings.srLatLang) {
    return 'ETF';
  } else {
    return 'ETF';
  }
}

String formatAnnouncementsBody(List<Announcement> announcements) {
  return announcements.map((a) => '• ${a.naslov}').join('\n');
}
