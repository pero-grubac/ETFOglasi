import 'package:etf_oglasi/core/gen/app_localizations.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/repository/bookmark_repository.dart';
import 'package:etf_oglasi/features/announcements/screen/bookmarks_screen.dart';
import 'package:etf_oglasi/features/announcements/service/bookmarks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _announcement(int id) => Announcement(
  id: id,
  naslov: 'Oglas $id',
  sadrzaj: 'Sadržaj $id',
  vrijemeKreiranja: DateTime(2026, 9, 1),
  vrijemeIsteka: DateTime(2100),
  oglasnaPloca: OglasnaPloca(id: 1),
  oglasPrilozi: const [],
);

class _FakeBookmarkRepository implements BookmarkRepository {
  final List<Announcement> stored = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Announcement>> findAll() async => [...stored];

  @override
  Future<void> save(Announcement announcement, DateTime savedAt) async =>
      stored.insert(0, announcement);

  @override
  Future<void> remove(int id) async => stored.removeWhere((a) => a.id == id);
}

void main() {
  test('toggle saves and removes an announcement', () async {
    final repository = _FakeBookmarkRepository();
    final container = ProviderContainer(
      overrides: [bookmarkRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(bookmarksProvider.notifier);
    await container.read(bookmarksProvider.future);

    expect(await notifier.toggle(_announcement(1)), isTrue);
    expect(await notifier.toggle(_announcement(2)), isTrue);
    expect(container.read(bookmarkedIdsProvider), {1, 2});
    // Newest first.
    expect(repository.stored.map((a) => a.id), [2, 1]);

    expect(await notifier.toggle(_announcement(1)), isFalse);
    expect(container.read(bookmarkedIdsProvider), {2});
    expect(repository.stored.map((a) => a.id), [2]);
  });

  testWidgets('saved announcements can be removed from their screen', (
    tester,
  ) async {
    final repository = _FakeBookmarkRepository()..stored.add(_announcement(7));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookmarkRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale.fromSubtags(
            languageCode: 'sr',
            scriptCode: 'Latn',
          ),
          home: const BookmarksScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Oglas 7'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tap(find.byTooltip('Više opcija'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukloni iz sačuvanih'));
    await tester.pumpAndSettle();

    expect(find.text('Oglas 7'), findsNothing);
    expect(find.textContaining('Nemate sačuvanih oglasa'), findsOneWidget);
    expect(repository.stored, isEmpty);
  });
}
