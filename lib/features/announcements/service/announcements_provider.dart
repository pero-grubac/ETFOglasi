import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnnouncementsResult {
  final List<Announcement> announcements;

  /// True when the network request failed and stored data is shown instead.
  final bool fromCache;

  /// Announcements the user hasn't seen on this board before.
  final Set<int> newIds;

  const AnnouncementsResult(
    this.announcements, {
    required this.fromCache,
    this.newIds = const {},
  });
}

/// Ids in [current] that are not in [seen]. Nothing counts as new when the
/// board was never opened ([seen] is `null`).
Set<int> newAnnouncementIds(Iterable<int> current, Set<int>? seen) {
  if (seen == null) return {};
  return current.where((id) => !seen.contains(id)).toSet();
}

/// Incremented whenever announcements are marked as seen or stored data may
/// have changed (app resumed after a background check), so unseen counts
/// refresh.
class SeenVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final seenVersionProvider = NotifierProvider<SeenVersionNotifier, int>(
  SeenVersionNotifier.new,
);

/// Announcements for a board URL: fetched from the API and stored, falling
/// back to the stored copy when offline. Loading marks them as seen.
final announcementsProvider = FutureProvider.autoDispose
    .family<AnnouncementsResult, String>((ref, url) async {
      final service = ref.watch(announcementServiceProvider);
      final repository = ref.watch(announcementRepositoryProvider);

      List<Announcement> announcements;
      var fromCache = false;
      try {
        announcements = await service.fetchAnnouncements(url);
        await repository.saveAnnouncements(url, announcements);
      } catch (_) {
        final cached = await repository.findAnnouncementsById(url);
        if (cached == null) rethrow;
        announcements = cached;
        fromCache = true;
      }

      final ids = announcements.map((a) => a.id).toSet();
      final newIds = newAnnouncementIds(ids, await repository.findSeenIds(url));
      await repository.saveSeenIds(url, ids);
      ref.read(seenVersionProvider.notifier).bump();
      return AnnouncementsResult(
        announcements,
        fromCache: fromCache,
        newIds: newIds,
      );
    });

/// Number of stored announcements on a board that the user hasn't seen yet
/// (e.g. found by the background check).
final unseenCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  url,
) async {
  ref.watch(seenVersionProvider);
  final repository = ref.watch(announcementRepositoryProvider);
  final stored = await repository.findAnnouncementsById(url);
  if (stored == null) return 0;
  return newAnnouncementIds(
    stored.map((a) => a.id),
    await repository.findSeenIds(url),
  ).length;
});
