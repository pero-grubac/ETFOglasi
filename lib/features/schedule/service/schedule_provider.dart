import 'dart:async';

import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleData {
  final Schedule schedule;

  /// True when the latest network request failed and stored data is shown.
  final bool offline;

  const ScheduleData(this.schedule, {this.offline = false});
}

/// Schedule for a URL. Stored data is shown right away and refreshed in the
/// background; only successful, non-empty responses are stored.
class ScheduleNotifier
    extends AutoDisposeFamilyAsyncNotifier<ScheduleData, String> {
  bool _disposed = false;

  @override
  Future<ScheduleData> build(String url) async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

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
    final schedule = await ref.read(scheduleServiceProvider).fetchSchedule(arg);
    if (schedule.isNotEmpty) {
      await ref.read(scheduleRepositoryProvider).saveSchedule(arg, schedule);
    }
    return schedule;
  }

  Future<void> _revalidate(Schedule cached) async {
    try {
      final fresh = await _fetchAndSave();
      if (!_disposed) state = AsyncData(ScheduleData(fresh));
    } catch (_) {
      if (!_disposed) state = AsyncData(ScheduleData(cached, offline: true));
    }
  }

  /// Fetches the schedule from the network. Returns false when it failed; the
  /// previously shown data is kept in that case.
  Future<bool> refresh() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<ScheduleData>().copyWithPrevious(state);
    try {
      final fresh = await _fetchAndSave();
      if (!_disposed) state = AsyncData(ScheduleData(fresh));
      return true;
    } catch (e, stackTrace) {
      if (!_disposed) {
        state = previous != null
            ? AsyncData(ScheduleData(previous.schedule, offline: true))
            : AsyncError(e, stackTrace);
      }
      return false;
    }
  }
}

final scheduleProvider = AsyncNotifierProvider.autoDispose
    .family<ScheduleNotifier, ScheduleData, String>(ScheduleNotifier.new);
