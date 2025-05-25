import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/data/repository/schedule_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleNotifier extends StateNotifier<Schedule?> {
  ScheduleNotifier(this._ref) : super(null);

  final Ref _ref;
  late final ScheduleRepository _repository =
      _ref.read(scheduleRepositoryProvider);

  Future<void> loadData(String url) async {
    final data = await _repository.findScheduleById(url);
    state = data;
  }

  Future<void> saveData(String url, Schedule schedule) async {
    await _repository.saveSchedule(url, schedule);
    state = schedule;
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, Schedule?>(
  (ref) => ScheduleNotifier(ref),
);
