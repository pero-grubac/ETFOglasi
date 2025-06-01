import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomScheduleURLNotifier extends StateNotifier<String?> {
  RoomScheduleURLNotifier(super.state);

  void updateId(String id) {
    state = id;
  }
}

final roomScheduleURLProvider =
    StateNotifierProvider<RoomScheduleURLNotifier, String?>((ref) {
  final localSettings = ref.watch(localSettingsProvider);
  return RoomScheduleURLNotifier(localSettings.classScheduleUrl);
});
