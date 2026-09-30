import 'package:etf_oglasi/core/navigation/notification_navigation.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/core/service/notification_service.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/home/screen/home_screen.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/gen/app_localizations.dart';
import 'features/settings/service/local_settings_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer();
  final settingsNotifier = container.read(localSettingsProvider.notifier);
  await settingsNotifier.loadSettings();
  final settings = container.read(localSettingsProvider);

  String? launchPayload;
  try {
    final notificationService = NotificationService();
    await notificationService.initialize(
      lookupAppLocalizations(LocalSettings.toLocale(settings.language)),
      onTap: openBoardFromNotification,
    );
    launchPayload = await notificationService.launchPayload();
    await AnnouncementWorkManager.initialize();
    await AnnouncementWorkManager.ensurePeriodicTasks(
      settings.notificationTimeSettings,
    );
  } catch (e) {
    debugPrint('Background notification setup failed: $e');
  }

  FlutterNativeSplash.remove();
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
  openBoardFromNotification(launchPayload);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
