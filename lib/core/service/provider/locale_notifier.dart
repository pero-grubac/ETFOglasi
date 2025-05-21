import 'dart:ui';

import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.state);
  void updateLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final localSettings = ref.watch(localSettingsProvider);
  final locale = Locale(localSettings.language);
  return LocaleNotifier(locale);
});
