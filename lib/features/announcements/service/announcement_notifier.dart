import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';

import '../../../core/gen/app_localizations.dart';

/// Announcement boards that can be watched for notifications, keyed by the
/// settings key used in [NotificationTimeSetting] maps.
const Map<String, String> notificationBoardIds = {
  'first_year': '1',
  'second_year': '2',
  'third_year': '3',
  'fourth_year': '4',
  'second_cycle': '20',
  'third_cycle': '30',
  'postgraduate_study': '102',
  'final_thesis': '21',
};

String notificationBoardTitle(AppLocalizations locale, String key) {
  return switch (key) {
    'first_year' => locale.firstYear,
    'second_year' => locale.secondYear,
    'third_year' => locale.thirdYear,
    'fourth_year' => locale.fourthYear,
    'second_cycle' => locale.secondCycle,
    'third_cycle' => locale.thirdCycle,
    'postgraduate_study' => locale.postgraduateStudy,
    'final_thesis' => locale.finalThesis,
    _ => key,
  };
}

/// Fetches the board, stores it and returns the announcements that were not
/// stored before.
///
/// When nothing was stored for [url] yet (first check), the list is only
/// saved and an empty list is returned, so the user isn't notified about
/// every existing announcement.
Future<List<Announcement>> fetchNewAnnouncements({
  required String url,
  required AnnouncementService service,
  required AnnouncementRepository repository,
}) async {
  final apiAnnouncements = await service.fetchAnnouncements(url);
  final dbAnnouncements = await repository.findAnnouncementsById(url);
  await repository.saveAnnouncements(url, apiAnnouncements);

  if (dbAnnouncements == null) return [];

  final dbIds = dbAnnouncements.map((a) => a.id).toSet();
  return apiAnnouncements.where((a) => !dbIds.contains(a.id)).toList();
}
