import 'dart:ui';

import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.state);
  void updateLocale(Locale locale) {
    state = locale;
  }
}

Locale parseLocale(String localeString) {
  final parts = localeString.split('-');
  if (parts.length == 2) {
    return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
  } else {
    return Locale(localeString);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final localSettings = ref.watch(localSettingsProvider);
  final locale = parseLocale(localSettings.language);
  return LocaleNotifier(locale);
});
