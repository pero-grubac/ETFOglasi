import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:flutter/widgets.dart';

import '../gen/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Finds the screen a notification belongs to: the announcement board (the
/// payload is the board id; older notifications used the board URL), or the
/// class schedule for class reminders.
Category? categoryForNotificationPayload(
  AppLocalizations locale,
  String payload,
) {
  for (final category in buildAvailableCategories(locale)) {
    if (payload == classSchedulePayload) {
      if (category.type == CategoryType.classSchedule) return category;
    } else if (category.boardId == payload ||
        category.announcementsUrl == payload) {
      return category;
    }
  }
  return null;
}

/// Opens the board of a tapped notification once the navigator is ready.
void openBoardFromNotification(String? payload) {
  if (payload == null) return;
  WidgetsBinding.instance
    ..addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      final context = navigatorKey.currentContext;
      if (navigator == null || context == null) return;

      final category = categoryForNotificationPayload(
        AppLocalizations.of(context),
        payload,
      );
      if (category == null) return;
      navigator.pushNamed(Routes.forCategory(category), arguments: category);
    })
    ..scheduleFrame();
}
