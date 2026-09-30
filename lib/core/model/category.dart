import 'package:etf_oglasi/core/config/api_constants.dart';

import '../gen/app_localizations.dart';

enum CategoryType { announcements, classSchedule, roomSchedule }

class Category {
  final int id;
  final String title;
  final CategoryType type;

  /// Announcement board id, only set for [CategoryType.announcements].
  final String? boardId;

  const Category({
    required this.id,
    required this.title,
    required this.type,
    this.boardId,
  });

  String? get announcementsUrl =>
      boardId != null ? getAnnouncementsUrl(boardId!) : null;
}

List<Category> buildAvailableCategories(AppLocalizations locale) {
  return [
    Category(
      id: 1,
      title: locale.firstYear,
      type: CategoryType.announcements,
      boardId: '1',
    ),
    Category(
      id: 2,
      title: locale.secondYear,
      type: CategoryType.announcements,
      boardId: '2',
    ),
    Category(
      id: 3,
      title: locale.thirdYear,
      type: CategoryType.announcements,
      boardId: '3',
    ),
    Category(
      id: 4,
      title: locale.fourthYear,
      type: CategoryType.announcements,
      boardId: '4',
    ),
    Category(
      id: 5,
      title: locale.classSchedule,
      type: CategoryType.classSchedule,
    ),
    Category(
      id: 6,
      title: locale.hallSchedule,
      type: CategoryType.roomSchedule,
    ),
    Category(
      id: 7,
      title: locale.secondCycle,
      type: CategoryType.announcements,
      boardId: '20',
    ),
    Category(
      id: 8,
      title: locale.thirdCycle,
      type: CategoryType.announcements,
      boardId: '30',
    ),
    Category(
      id: 9,
      title: locale.postgraduateStudy,
      type: CategoryType.announcements,
      boardId: '102',
    ),
    Category(
      id: 10,
      title: locale.finalThesis,
      type: CategoryType.announcements,
      boardId: '21',
    ),
  ];
}
