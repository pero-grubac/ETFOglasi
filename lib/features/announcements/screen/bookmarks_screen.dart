import 'package:etf_oglasi/core/ui/widget/api_error_widget.dart';
import 'package:etf_oglasi/core/ui/widget/no_data_widget.dart';
import 'package:etf_oglasi/features/announcements/service/bookmarks_provider.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

/// Saved announcements, from the local database (works offline).
class BookmarksScreen extends ConsumerWidget {
  static const id = 'bookmarks_screen';
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context);
    final bookmarks = ref.watch(bookmarksProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(locale.bookmarks)),
      body: bookmarks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ApiErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(bookmarksProvider),
        ),
        data: (announcements) => announcements.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: NoDataWidget(message: locale.noBookmarks),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return AnnouncementCard(
                    announcement: announcement,
                    isExpired: announcement.isExpiredAt(now),
                  );
                },
              ),
      ),
    );
  }
}
