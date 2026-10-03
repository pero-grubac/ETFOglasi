import 'dart:async';

import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/service/saved_schedule_sync.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleData {
  final Schedule schedule;

  /// True when the latest network request failed and stored data is shown.
  final bool offline;

  /// True while [schedule] is shown and a manual refresh is running.
  final bool refreshing;

  const ScheduleData(
    this.schedule, {
    this.offline = false,
    this.refreshing = false,
  });
}

/// Schedule for a URL. Stored data is shown right away and refreshed in the
/// background; only successful, non-empty responses are stored.
class ScheduleNotifier extends AsyncNotifier<ScheduleData> {
  ScheduleNotifier(this.url);

  final String url;

  @override
  Future<ScheduleData> build() async {
    final cached = await ref
        .read(scheduleRepositoryProvider)
        .findScheduleById(url);
    if (cached != null) {
      unawaited(Future(() => _revalidate(cached)));
      return ScheduleData(cached);
    }
    return ScheduleData(await _fetchAndSave());
  }

  Future<Schedule> _fetchAndSave() async {
    final schedule = await ref.read(scheduleServiceProvider).fetchSchedule(url);
    if (schedule.isNotEmpty) {
      await ref.read(scheduleRepositoryProvider).saveSchedule(url, schedule);
      // Reminders and the widget are built from the saved schedule.
      if (ref.read(localSettingsProvider).classScheduleUrl == url) {
        unawaited(ref.read(savedScheduleSyncProvider).sync());
      }
    }
    return schedule;
  }

  Future<void> _revalidate(Schedule cached) async {
    try {
      final fresh = await _fetchAndSave();
      if (ref.mounted) state = AsyncData(ScheduleData(fresh));
    } catch (_) {
      if (ref.mounted) state = AsyncData(ScheduleData(cached, offline: true));
    }
  }

  /// Fetches the schedule from the network. Returns false when it failed; the
  /// previously shown data is kept in that case.
  Future<bool> refresh() async {
    final previous = state.value;
    state = previous != null
        ? AsyncData(
            ScheduleData(
              previous.schedule,
              offline: previous.offline,
              refreshing: true,
            ),
          )
        : const AsyncLoading<ScheduleData>();
    try {
      final fresh = await _fetchAndSave();
      if (ref.mounted) state = AsyncData(ScheduleData(fresh));
      return true;
    } catch (e, stackTrace) {
      if (ref.mounted) {
        state = previous != null
            ? AsyncData(ScheduleData(previous.schedule, offline: true))
            : AsyncError(e, stackTrace);
      }
      return false;
    }
  }
}

final scheduleProvider = AsyncNotifierProvider.autoDispose
    .family<ScheduleNotifier, ScheduleData, String>(
      ScheduleNotifier.new,
      // The screen has its own retry button.
      retry: (_, _) => null,
    );
