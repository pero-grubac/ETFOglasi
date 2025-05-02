import 'package:flutter/material.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/features/home/constants/strings.dart';

class Category {
  final int id;
  final String title;
  final String urlId;
  final Route<dynamic> route;

  const Category({
    required this.id,
    required this.title,
    required this.urlId,
    required this.route,
  });
}

final List<Category> availableCategories = [
  Category(
    id: 1,
    title: HomeStrings.firstYear,
    urlId: '1',
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.announcementScreen),
      pageBuilder: (_, __, ___) =>
          const Placeholder(), // Placeholder widget (not used)
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 2,
    title: HomeStrings.secondYear,
    urlId: '2',
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
    urlId: '3',
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
    urlId: '4',
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
    urlId: '1',
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
    urlId: '1',
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
    urlId: '1',
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.placeholderScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 8,
    title: HomeStrings.thirdCycle,
    urlId: '1',
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.placeholderScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 9,
    title: HomeStrings.postgraduateStudy,
    urlId: '1',
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.placeholderScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
  Category(
    id: 10,
    title: HomeStrings.finalThesis,
    urlId: '1',
    route: PageRouteBuilder(
      settings: const RouteSettings(name: Routes.placeholderScreen),
      pageBuilder: (_, __, ___) => const Placeholder(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
];
