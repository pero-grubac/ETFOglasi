import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:flutter/widgets.dart';

import '../gen/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Finds the announcement board a notification belongs to. The payload is the
/// board id (older notifications used the board URL).
Category? categoryForNotificationPayload(
  AppLocalizations locale,
  String payload,
) {
  for (final category in buildAvailableCategories(locale)) {
    if (category.boardId == payload || category.announcementsUrl == payload) {
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
