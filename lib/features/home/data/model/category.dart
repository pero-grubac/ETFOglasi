import 'package:etf_oglasi/config/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/features/home/constants/strings.dart';

class Category {
  final int id;
  final String title;
  final String url;
  final Route<dynamic> route;

  const Category({
    required this.id,
    required this.title,
    required this.url,
    required this.route,
  });
}

final List<Category> availableCategories = [
  Category(
    id: 1,
    title: HomeStrings.firstYear,
    url: getAnnouncementsUrl("1"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 2,
    title: HomeStrings.secondYear,
    url: getAnnouncementsUrl("2"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 3,
    title: HomeStrings.thirdYear,
    url: getAnnouncementsUrl("3"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 4,
    title: HomeStrings.fourthYear,
    url: getAnnouncementsUrl("4"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 5,
    title: HomeStrings.classSchedule,
    url: getScheduleUrl("1", "1"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.scheduleScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 6,
    title: HomeStrings.hallSchedule,
    url: getScheduleUrl("1", "1"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.scheduleScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 7,
    title: HomeStrings.secondCycle,
    url: getAnnouncementsUrl("20"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 8,
    title: HomeStrings.thirdCycle,
    url: getAnnouncementsUrl("30"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 9,
    title: HomeStrings.postgraduateStudy,
    url: getAnnouncementsUrl("102"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 10,
    title: HomeStrings.finalThesis,
    url: getAnnouncementsUrl("21"),
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
];
