import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saved announcements, newest first.
class BookmarksNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() =>
      ref.read(bookmarkRepositoryProvider).findAll();

  /// Saves or removes [announcement]. Returns whether it is saved now.
  Future<bool> toggle(Announcement announcement) async {
    final repository = ref.read(bookmarkRepositoryProvider);
    final current = state.value ?? await future;
    final saved = current.any((a) => a.id == announcement.id);
    if (saved) {
      await repository.remove(announcement.id);
      state = AsyncData([
        for (final a in current)
          if (a.id != announcement.id) a,
      ]);
    } else {
      await repository.save(announcement, DateTime.now());
      state = AsyncData([announcement, ...current]);
    }
    return !saved;
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<Announcement>>(
      BookmarksNotifier.new,
      retry: (_, _) => null,
    );

/// Ids of the saved announcements (empty while loading or on error).
final bookmarkedIdsProvider = Provider<Set<int>>(
  (ref) =>
      ref.watch(bookmarksProvider).value?.map((a) => a.id).toSet() ?? const {},
);
