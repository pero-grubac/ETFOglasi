import 'package:etf_oglasi/core/gen/app_localizations.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/core/ui/widget/api_error_widget.dart';
import 'package:etf_oglasi/core/ui/widget/offline_banner.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/screen/announcement_screen.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/repository/schedule_repository.dart';
import 'package:etf_oglasi/features/schedule/screen/schedule_screen.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_service.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _announcement(int id, {bool withAttachment = false}) =>
    Announcement(
      id: id,
      naslov: 'Oglas $id',
      sadrzaj: 'Sadržaj oglasa $id ' * 40,
      potpis: 'Prof. X',
      vrijemeKreiranja: DateTime(2026, 9, 1, 10),
      vrijemeIsteka: DateTime(2026, 10, 1),
      oglasnaPloca: OglasnaPloca(id: 1),
      oglasPrilozi: withAttachment
          ? [
              OglasPrilog(
                id: 1,
                naziv: 'a',
                velicina: 10,
                originalniNaziv: 'raspored.pdf',
                ekstenzija: 'pdf',
              ),
            ]
          : const [],
    );

class _FakeAnnouncementService extends AnnouncementService {
  _FakeAnnouncementService({this.fail = false}) : super(service: ApiService());
  final bool fail;

  @override
  Future<List<Announcement>> fetchAnnouncements(String url) async {
    if (fail) throw ApiException('offline', null);
    return [_announcement(1, withAttachment: true), _announcement(2)];
  }
}

class _FakeAnnouncementRepository implements AnnouncementRepository {
  _FakeAnnouncementRepository([this.cached, this.seen]);
  final List<Announcement>? cached;
  Set<int>? seen;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Announcement>?> findAnnouncementsById(String id) async => cached;

  @override
  Future<void> saveAnnouncements(String id, List<Announcement> list) async {}

  @override
  Future<Set<int>?> findSeenIds(String id) async => seen;

  @override
  Future<void> saveSeenIds(String id, Set<int> ids) async => seen = ids;
}

class _FakeScheduleService extends ScheduleService {
  _FakeScheduleService({this.fail = false}) : super(service: ApiService());
  final bool fail;
  int calls = 0;
  final List<String> urls = [];

  @override
  Future<Schedule> fetchSchedule(String url) async {
    calls++;
    urls.add(url);
    if (fail) throw ApiException('offline', null);
    return parseScheduleRows([
      for (var h = 8; h < 20; h++)
        ['$h:15', 'Predmet $h', null, 'Lab $h', null, null, null, null],
    ]);
  }
}

class _FakeScheduleRepository implements ScheduleRepository {
  _FakeScheduleRepository([this.cached]);
  Schedule? cached;
  final List<Schedule> saved = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Schedule?> findScheduleById(String id) async => cached;

  @override
  Future<void> saveSchedule(String id, Schedule schedule) async {
    saved.add(schedule);
  }
}

class _TestSettingsNotifier extends LocalSettingsNotifier {
  _TestSettingsNotifier(this.initial);
  final LocalSettings initial;

  @override
  LocalSettings build() => initial;
}

Widget _app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    home: home,
  ),
);

/// A small phone (360×740 dp) with the system font size at [textScale].
void _usePhone(WidgetTester tester, {double textScale = 1}) {
  final view = tester.view;
  view.physicalSize = const Size(1080, 2220);
  view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

const _announcementCategory = Category(
  id: 1,
  title: 'Prva godina',
  type: CategoryType.announcements,
  boardId: '1',
);

const _roomScheduleCategory = Category(
  id: 6,
  title: 'Raspored zauzetosti sala',
  type: CategoryType.roomSchedule,
);

const _classScheduleCategory = Category(
  id: 5,
  title: 'Raspored nastave',
  type: CategoryType.classSchedule,
);

void main() {
  group('AnnouncementScreen', () {
    testWidgets('shows announcements from the API', (tester) async {
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oglas 1'), findsOneWidget);
      expect(find.text('Prilog: raspored.pdf'), findsOneWidget);
      expect(find.text('Prikaži više'), findsWidgets);
      expect(find.byType(OfflineBanner), findsNothing);
    });

    testWidgets('falls back to stored announcements when offline', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(fail: true),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository([_announcement(7)]),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('Oglas 7'), findsOneWidget);
    });

    testWidgets('shows an error when offline without stored data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(fail: true),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ApiErrorWidget), findsOneWidget);
    });

    testWidgets('marks announcements not seen before as new', (tester) async {
      final repository = _FakeAnnouncementRepository(null, {1});
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(repository),
        ]),
      );
      await tester.pumpAndSettle();

      // Announcement 2 is new, 1 was seen.
      expect(find.text('Novo'), findsOneWidget);
      expect(repository.seen, {1, 2});

      // The badge stays after a refresh during the same visit.
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('Novo'), findsOneWidget);
    });

    testWidgets('nothing is new on the first visit', (tester) async {
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Novo'), findsNothing);
    });

    testWidgets('search filters announcements', (tester) async {
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'oglas 2');
      await tester.pumpAndSettle();

      expect(find.text('Oglas 1'), findsNothing);
      expect(find.text('Oglas 2'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nepostojece');
      await tester.pumpAndSettle();
      expect(find.text('Nema rezultata pretrage'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Oglas 1'), findsOneWidget);
    });

    testWidgets('copies an announcement from the card menu', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kopiraj tekst'));
      await tester.pumpAndSettle();

      expect(copied, startsWith('Oglas 1'));
      expect(find.text('Tekst je kopiran'), findsOneWidget);
    });
  });

  group('ScheduleScreen', () {
    List<Override> overrides(
      _FakeScheduleService service,
      _FakeScheduleRepository repository, {
      String? classScheduleUrl = 'https://example.com/schedule',
    }) => [
      scheduleServiceProvider.overrideWithValue(service),
      scheduleRepositoryProvider.overrideWithValue(repository),
      localSettingsProvider.overrideWith(
        () => _TestSettingsNotifier(
          LocalSettings(classScheduleUrl: classScheduleUrl),
        ),
      ),
    ];

    testWidgets('fetches, shows and stores the schedule', (tester) async {
      final service = _FakeScheduleService();
      final repository = _FakeScheduleRepository();

      await tester.pumpWidget(
        _app(
          const ScheduleScreen(category: _classScheduleCategory),
          overrides(service, repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
      expect(repository.saved, hasLength(1));
    });

    testWidgets('a failed fetch is not stored', (tester) async {
      final repository = _FakeScheduleRepository();

      await tester.pumpWidget(
        _app(
          const ScheduleScreen(category: _classScheduleCategory),
          overrides(_FakeScheduleService(fail: true), repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ApiErrorWidget), findsOneWidget);
      expect(repository.saved, isEmpty);
    });

    testWidgets('shows stored data and refreshes it in the background', (
      tester,
    ) async {
      final service = _FakeScheduleService();
      final repository = _FakeScheduleRepository(
        Schedule.empty()
          ..monday.add(ScheduleEntry(time: '8:15', subject: 'Stari')),
      );

      await tester.pumpWidget(
        _app(
          const ScheduleScreen(category: _classScheduleCategory),
          overrides(service, repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.calls, 1);
      expect(repository.saved, hasLength(1));
    });

    testWidgets('keeps stored data and shows a banner when offline', (
      tester,
    ) async {
      final repository = _FakeScheduleRepository(
        Schedule.empty()
          ..monday.add(ScheduleEntry(time: '8:15', subject: 'Stari')),
      );

      await tester.pumpWidget(
        _app(
          const ScheduleScreen(category: _classScheduleCategory),
          overrides(_FakeScheduleService(fail: true), repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('asks to pick a schedule when none is saved', (tester) async {
      await tester.pumpWidget(
        _app(
          const ScheduleScreen(category: _classScheduleCategory),
          overrides(
            _FakeScheduleService(),
            _FakeScheduleRepository(),
            classScheduleUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Raspored nije izabran'), findsOneWidget);
    });

    testWidgets('room schedule can move between weeks', (tester) async {
      final service = _FakeScheduleService();
      await tester.pumpWidget(
        _app(const ScheduleScreen(category: _roomScheduleCategory), [
          scheduleServiceProvider.overrideWithValue(service),
          scheduleRepositoryProvider.overrideWithValue(
            _FakeScheduleRepository(),
          ),
          localSettingsProvider.overrideWith(
            () =>
                _TestSettingsNotifier(const LocalSettings(roomScheduleId: '7')),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      final week = defaultScheduleWeek(DateTime.now());
      expect(service.urls.last, getRoomScheduleUrl('7', formatDate(week)));
      expect(find.text(formatWeekRange(week)), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(
        service.urls.last,
        getRoomScheduleUrl('7', formatDate(addWeeks(week, 1))),
      );

      // Tapping the range goes back to the default week.
      await tester.tap(find.text(formatWeekRange(addWeeks(week, 1))));
      await tester.pumpAndSettle();
      expect(find.text(formatWeekRange(week)), findsOneWidget);
    });
  });

  // Overflows are reported as test failures, so these catch text that
  // doesn't fit when the user picks a large system font.
  group('large text (200%)', () {
    testWidgets('announcements fit', (tester) async {
      _usePhone(tester, textScale: 2);
      await tester.pumpWidget(
        _app(const AnnouncementScreen(category: _announcementCategory), [
          announcementServiceProvider.overrideWithValue(
            _FakeAnnouncementService(),
          ),
          announcementRepositoryProvider.overrideWithValue(
            _FakeAnnouncementRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oglas 1'), findsOneWidget);
    });

    testWidgets('class schedule fits', (tester) async {
      _usePhone(tester, textScale: 2);
      await tester.pumpWidget(
        _app(const ScheduleScreen(category: _classScheduleCategory), [
          scheduleServiceProvider.overrideWithValue(_FakeScheduleService()),
          scheduleRepositoryProvider.overrideWithValue(
            _FakeScheduleRepository(),
          ),
          localSettingsProvider.overrideWith(
            () => _TestSettingsNotifier(
              const LocalSettings(
                classScheduleUrl: 'https://example.com/schedule',
              ),
            ),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('room schedule week navigation fits', (tester) async {
      _usePhone(tester, textScale: 2);
      await tester.pumpWidget(
        _app(const ScheduleScreen(category: _roomScheduleCategory), [
          scheduleServiceProvider.overrideWithValue(_FakeScheduleService()),
          scheduleRepositoryProvider.overrideWithValue(
            _FakeScheduleRepository(),
          ),
          localSettingsProvider.overrideWith(
            () => _TestSettingsNotifier(
              const LocalSettings(roomScheduleId: '105'),
            ),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
