import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/home/screen/home_screen.dart';
import 'package:etf_oglasi/features/settings/service/locale_notifier.dart';
import 'package:etf_oglasi/features/settings/service/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/gen/app_localizations.dart';
import 'features/settings/service/local_settings_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPreferences.getInstance();
  await AnnouncementWorkManager.initialize();

  final container = ProviderContainer();
  await container.read(localSettingsProvider.notifier).loadSettings();
  FlutterNativeSplash.remove();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const HomeScreen(),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
