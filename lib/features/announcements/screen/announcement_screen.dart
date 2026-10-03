import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/ui/widget/api_error_widget.dart';
import 'package:etf_oglasi/core/ui/widget/no_data_widget.dart';
import 'package:etf_oglasi/core/ui/widget/offline_banner.dart';
import 'package:etf_oglasi/core/util/text_search.dart';
import 'package:etf_oglasi/features/announcements/service/announcements_provider.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

class AnnouncementScreen extends ConsumerStatefulWidget {
  static const id = 'announcement_screen';
  const AnnouncementScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  /// New announcements found during this visit. Kept across refreshes, which
  /// mark everything as seen.
  final Set<int> _newIds = {};

  FutureProvider<AnnouncementsResult> get _provider =>
      announcementsProvider(widget.category.announcementsUrl!);

  @override
  void initState() {
    super.initState();
    ref.listenManual(_provider, (_, next) {
      final newIds = next.value?.newIds;
      if (newIds != null && newIds.isNotEmpty) {
        setState(() => _newIds.addAll(newIds));
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      ref.invalidate(_provider);
      await ref.read(_provider.future);
    } catch (_) {
      // The error is shown by the error state.
    }
  }

  void _setSearching(bool searching) {
    setState(() {
      _isSearching = searching;
      if (!searching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  List<Announcement> _filter(List<Announcement> announcements) {
    if (_query.trim().isEmpty) return announcements;
    return announcements
        .where(
          (a) => matchesSearch(_query, [a.naslov, a.uvod, a.sadrzaj, a.potpis]),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final data = ref.watch(_provider);

    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setSearching(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: locale.search,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                )
              : Text(widget.category.title),
          centerTitle: !_isSearching,
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _setSearching(false),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _setSearching(true),
                tooltip: locale.search,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: data.isLoading ? null : _refresh,
                tooltip: locale.refresh,
              ),
            ],
          ],
          bottom: data.isLoading && data.hasValue
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(4),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
        body: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ApiErrorWidget(error: error, onRetry: _refresh),
          data: (result) {
            final now = DateTime.now();
            final announcements = sortExpiredLast(
              _filter(result.announcements),
              now,
            );
            final emptyMessage = result.announcements.isEmpty
                ? locale.noNotifications
                : locale.noSearchResults;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: announcements.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: NoDataWidget(message: emptyMessage),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      itemCount:
                          announcements.length + (result.fromCache ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (result.fromCache) {
                          if (index == 0) return const OfflineBanner();
                          index--;
                        }
                        final announcement = announcements[index];
                        return AnnouncementCard(
                          announcement: announcement,
                          isNew: _newIds.contains(announcement.id),
                          isExpired: announcement.isExpiredAt(now),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
