import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/service/notification_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_widget.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

/// Keeps what is built from the saved class schedule up to date: the class
/// reminders and the home screen widget. Call on app start and whenever the
/// saved schedule, its data, the reminder setting or the language changes.
class SavedScheduleSync {
  SavedScheduleSync(this._ref, {NotificationService? notifications})
    : _notifications = notifications ?? NotificationService();

  final Ref _ref;
  final NotificationService _notifications;

  Future<void> sync() async {
    final settings = _ref.read(localSettingsProvider);
    final locale = lookupAppLocalizations(
      LocalSettings.toLocale(settings.language),
    );
    final url = settings.classScheduleUrl;

    try {
      final schedule = url == null
          ? null
          : await _ref.read(scheduleRepositoryProvider).findScheduleById(url);

      await _syncReminders(schedule, settings.classReminderMinutes, locale);
      await _syncWidget(schedule, locale);
    } catch (e, stackTrace) {
      await errorLog.record(e, stackTrace, source: 'saved schedule sync');
    }
  }

  Future<void> _syncReminders(
    Schedule? schedule,
    int minutes,
    AppLocalizations locale,
  ) async {
    try {
      await _notifications.cancelClassReminders();
      if (schedule == null || minutes <= 0) return;
      await _notifications.scheduleClassReminders(
        buildClassReminders(scheduleBlocks(schedule), minutes, locale),
        locale: locale,
        location: facultyTimeZone(),
      );
    } catch (e, stackTrace) {
      await errorLog.record(e, stackTrace, source: 'class reminders');
    }
  }

  Future<void> _syncWidget(Schedule? schedule, AppLocalizations locale) async {
    try {
      await updateScheduleWidget(schedule, locale);
    } catch (e, stackTrace) {
      await errorLog.record(e, stackTrace, source: 'schedule widget');
    }
  }
}

final savedScheduleSyncProvider = Provider<SavedScheduleSync>(
  SavedScheduleSync.new,
);
