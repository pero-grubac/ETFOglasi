import 'package:etf_oglasi/core/gen/app_localizations.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/home/screen/home_screen.dart';
import 'package:etf_oglasi/features/home/widget/category_grid_item.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/screen/settings_screen.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _latin = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

Announcement _announcement(int id) => Announcement(
  id: id,
  naslov: 'Oglas $id',
  sadrzaj: '',
  vrijemeKreiranja: DateTime(2026),
  vrijemeIsteka: DateTime(2026, 2),
  oglasnaPloca: OglasnaPloca(id: 1),
  oglasPrilozi: const [],
);

/// Board 1 has three stored announcements, one of which was seen.
class _FakeAnnouncementRepository implements AnnouncementRepository {
  final String _board1 = const Category(
    id: 1,
    title: '',
    type: CategoryType.announcements,
    boardId: '1',
  ).announcementsUrl!;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Announcement>?> findAnnouncementsById(String id) async =>
      id == _board1
      ? [_announcement(1), _announcement(2), _announcement(3)]
      : null;

  @override
  Future<Set<int>?> findSeenIds(String id) async => id == _board1 ? {1} : null;
}

class _TestSettingsNotifier extends LocalSettingsNotifier {
  @override
  LocalSettings build() => const LocalSettings(themeMode: ThemeMode.light);

  // Skip SharedPreferences in tests.
  @override
  void updateTheme(ThemeMode themeMode) =>
      state = state.copyWith(themeMode: themeMode);
}

Widget _app(Widget home, {Locale locale = _latin}) => ProviderScope(
  overrides: [
    announcementRepositoryProvider.overrideWithValue(
      _FakeAnnouncementRepository(),
    ),
    localSettingsProvider.overrideWith(_TestSettingsNotifier.new),
  ],
  child: MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: home,
  ),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 3000);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('home screen shows all categories', (tester) async {
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryGridItem), findsNWidgets(10));
    expect(find.text('Prva godina'), findsOneWidget);
    expect(find.text('Raspored nastave'), findsOneWidget);
  });

  testWidgets('home screen shows the number of unseen announcements', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('home screen is localized in Cyrillic', (tester) async {
    await tester.pumpWidget(
      _app(
        const HomeScreen(),
        locale: const Locale.fromSubtags(
          languageCode: 'sr',
          scriptCode: 'Cyrl',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Прва година'), findsOneWidget);
  });

  testWidgets('theme can follow the system setting', (tester) async {
    await tester.pumpWidget(_app(const SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sistemska'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
