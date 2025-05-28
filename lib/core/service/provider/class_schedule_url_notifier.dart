import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassScheduleURLNotifier extends StateNotifier<String?> {
  ClassScheduleURLNotifier(super.state);
  void updateUrl(String url) {
    state = url;
  }
}

final classScheduleURLProvider =
    StateNotifierProvider<ClassScheduleURLNotifier, String?>((ref) {
  final localSettings = ref.watch(localSettingsProvider);
  return ClassScheduleURLNotifier(localSettings.classScheduleUrl);
});
