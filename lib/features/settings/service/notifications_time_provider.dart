import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsTimeNotifier
    extends StateNotifier<Map<String, NotificationTimeSetting>> {
  NotificationsTimeNotifier(super.state);
  void updateNotificationsTime(
      Map<String, NotificationTimeSetting> notificationsTime) {
    state = notificationsTime;
  }
}

final notificationsTimeNotifierProvider = StateNotifierProvider<
    NotificationsTimeNotifier, Map<String, NotificationTimeSetting>>(
  (ref) {
    final localSettings = ref.watch(localSettingsProvider);
    return NotificationsTimeNotifier(localSettings.notificationTimeSettings);
  },
);
