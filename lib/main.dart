import 'dart:async';

import 'package:etf_oglasi/core/navigation/notification_navigation.dart';
import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/service/notification_service.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:etf_oglasi/features/schedule/service/saved_schedule_sync.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_widget.dart';
import 'package:etf_oglasi/features/home/screen/home_screen.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/gen/app_localizations.dart';
import 'features/settings/service/local_settings_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  _recordUncaughtErrors();

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
    await AnnouncementWorkManager.syncPeriodicTask(
      settings.notificationTimeSettings,
    );
  } catch (e, stackTrace) {
    await errorLog.record(e, stackTrace, source: 'notification setup');
  }

  FlutterNativeSplash.remove();
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
  openBoardFromNotification(launchPayload);

  // Reminders and the widget, after the first frame so they don't delay the
  // start. Also restores reminders after an app update (reboots are handled
  // by the notification plugin).
  unawaited(container.read(savedScheduleSyncProvider).sync());
  unawaited(_handleWidgetLaunches());
}

/// Tapping the home screen widget opens the class schedule.
Future<void> _handleWidgetLaunches() async {
  void open(Uri? uri) {
    if (uri?.toString() == scheduleWidgetUri) {
      openBoardFromNotification(classSchedulePayload);
    }
  }

  try {
    open(await HomeWidget.initiallyLaunchedFromHomeWidget());
    HomeWidget.widgetClicked.listen(open);
  } catch (e, stackTrace) {
    await errorLog.record(e, stackTrace, source: 'widget launch');
  }
}

/// Stores uncaught errors in the local [ErrorLog] (Settings → Error log).
void _recordUncaughtErrors() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLog.record(details.exception, details.stack, source: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    errorLog.record(error, stackTrace, source: 'platform');
    return true;
  };
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
