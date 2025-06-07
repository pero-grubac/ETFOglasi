import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/features/schedule/widget/class_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/schedule/widget/room_schedule_settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen/app_localizations.dart';

class Category {
  final int id;
  final String title;
  final String? url;
  final String screenId;
  final Widget? settingsWidget;
  const Category({
    required this.id,
    required this.title,
    required this.url,
    required this.screenId,
    this.settingsWidget,
  });
}

List<Category> buildAvailableCategories(
    AppLocalizations locale, WidgetRef ref) {
  return [
    Category(
      id: 1,
      title: locale.firstYear,
      url: getAnnouncementsUrl("1"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 2,
      title: locale.secondYear,
      url: getAnnouncementsUrl("2"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 3,
      title: locale.thirdYear,
      url: getAnnouncementsUrl("3"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 4,
      title: locale.fourthYear,
      url: getAnnouncementsUrl("4"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 5,
      title: locale.classSchedule,
      url: ClassScheduleSettingsWidget.classScheduleUrl,
      settingsWidget: const ClassScheduleSettingsWidget(),
      screenId: Routes.scheduleScreen,
    ),
    Category(
      id: 6,
      title: locale.hallSchedule,
      url: RoomScheduleSettingsWidget.roomScheduleId,
      settingsWidget: const RoomScheduleSettingsWidget(),
      screenId: Routes.scheduleScreen,
    ),
    Category(
      id: 7,
      title: locale.secondCycle,
      url: getAnnouncementsUrl("20"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 8,
      title: locale.thirdCycle,
      url: getAnnouncementsUrl("30"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 9,
      title: locale.postgraduateStudy,
      url: getAnnouncementsUrl("102"),
      screenId: Routes.announcementScreen,
    ),
    Category(
      id: 10,
      title: locale.finalThesis,
      url: getAnnouncementsUrl("21"),
      screenId: Routes.announcementScreen,
    ),
  ];
}
