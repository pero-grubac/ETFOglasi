// Runs the real app on a device or emulator, with real SQLite and
// SharedPreferences. Only the network is faked, so the test doesn't depend
// on the ETF server. A plain `flutter test` runs on the computer and skips
// it; run it on a phone or emulator:
//
//   flutter drive --driver=test/integration/driver.dart \
//       --target=test/integration/app_test.dart -d <device id>
import 'dart:io';

import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/update_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/repository/schedule_repository.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:etf_oglasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sql;

const _classScheduleUrl = 'https://example.com/raspored';

Announcement _announcement(int id) => Announcement(
  id: id,
  naslov: 'Test oglas $id',
  sadrzaj: 'Sadržaj $id',
  vrijemeKreiranja: DateTime(2026, 9, 1),
  vrijemeIsteka: DateTime(2100),
  oglasnaPloca: OglasnaPloca(id: 1),
  oglasPrilozi: const [],
);

class _FakeAnnouncementService extends AnnouncementService {
  _FakeAnnouncementService() : super(service: ApiService());

  @override
  Future<List<Announcement>> fetchAnnouncements(String url) async => [
    _announcement(1),
    _announcement(2),
  ];
}

class _FakeScheduleService extends ScheduleService {
  _FakeScheduleService() : super(service: ApiService());

  @override
  Future<Schedule> fetchSchedule(String url) async => parseScheduleRows([
    for (var h = 8; h < 20; h++)
      ['$h:15', for (var day = 0; day < 5; day++) 'Predmet $h', null, null],
  ]);
}

class _NoUpdateService extends UpdateService {
  _NoUpdateService() : super(service: ApiService());

  @override
  Future<AppRelease?> findUpdate(String currentVersion) async => null;
}

/// Only on a device; on the computer there's no SQLite or app to run.
final bool _onDevice = Platform.isAndroid;

void main() {
  if (_onDevice) IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Start from a clean install.
    await sql.deleteDatabase(path.join(await sql.getDatabasesPath(), 'etf.db'));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString(LocalSettings.classScheduleUrlKey, _classScheduleUrl);
    await prefs.setString(LocalSettings.languageKey, LocalSettings.srLatLang);
  });

  testWidgets(
    'announcements, schedule and settings work end to end',
    skip: !_onDevice,
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          scheduleServiceProvider.overrideWithValue(_FakeScheduleService()),
          updateServiceProvider.overrideWithValue(_NoUpdateService()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(localSettingsProvider.notifier).loadSettings();

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();

      // Announcements: shown and stored in SQLite.
      await tester.tap(find.text('Prva godina'));
      await tester.pumpAndSettle();
      expect(find.text('Test oglas 1'), findsOneWidget);
      expect(find.text('Test oglas 2'), findsOneWidget);

      final announcementRepository = AnnouncementRepository(
        dbHelper: DatabaseHelper(),
      );
      final stored = await tester.runAsync(
        () => announcementRepository.findAnnouncementsById(
          'https://efee.etf.unibl.org:8443/api/public/oglasne-ploce/1',
        ),
      );
      expect(stored?.map((a) => a.id), [1, 2]);

      await tester.binding.handlePopRoute(); // system back
      await tester.pumpAndSettle();

      // Class schedule: fetched, shown and stored.
      await tester.tap(find.text('Raspored nastave'));
      await tester.pumpAndSettle();
      // The list scrolls to the current hour, so any subject will do.
      expect(find.textContaining('Predmet '), findsWidgets);

      final storedSchedule = await tester.runAsync(
        () => ScheduleRepository(
          dbHelper: DatabaseHelper(),
        ).findScheduleById(_classScheduleUrl),
      );
      expect(storedSchedule?.isNotEmpty, isTrue);

      await tester.binding.handlePopRoute(); // system back
      await tester.pumpAndSettle();

      // Settings: the theme is applied and saved.
      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Podešavanja'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tamna'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalSettings.themeModeKey), 'dark');
    },
  );
}
