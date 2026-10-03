import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/ui/theme/announcement_card_theme.dart';
import 'package:etf_oglasi/core/ui/widget/expandable_text_widget.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/features/announcements/service/bookmarks_provider.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_share.dart';
import 'package:etf_oglasi/features/announcements/widget/attachment_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/date_row_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/signature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/gen/app_localizations.dart';

enum _CardAction { bookmark, share, copy }

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isNew = false,
    this.isExpired = false,
  });
  final Announcement announcement;

  /// Shows a "new" badge (announcement not seen before).
  final bool isNew;

  /// Dims the card and shows an "expired" badge.
  final bool isExpired;

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _CardAction action,
  ) async {
    final locale = AppLocalizations.of(context);
    final text = announcementShareText(announcement, locale);
    switch (action) {
      case _CardAction.bookmark:
        final messenger = ScaffoldMessenger.of(context);
        try {
          final saved = await ref
              .read(bookmarksProvider.notifier)
              .toggle(announcement);
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                saved ? locale.bookmarkSaved : locale.bookmarkRemoved,
              ),
            ),
          );
        } catch (e, stackTrace) {
          await errorLog.record(e, stackTrace, source: 'bookmark');
          messenger.showSnackBar(
            SnackBar(content: Text(locale.bookmarkFailed)),
          );
        }
      case _CardAction.share:
        await SharePlus.instance.share(
          ShareParams(text: text, subject: announcement.naslov),
        );
      case _CardAction.copy:
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(locale.copied)));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(
      bookmarkedIdsProvider.select((ids) => ids.contains(announcement.id)),
    );
    final theme = Theme.of(context);
    final effectiveTheme =
        theme.extension<AnnouncementCardTheme>() ??
        AnnouncementCardTheme(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: theme.colorScheme.onSurface,
          textStyle: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
    final foreground = effectiveTheme.foregroundColor;
    final locale = AppLocalizations.of(context);
    final boxShadow = effectiveTheme.decoration.boxShadow;
    final borderRadius =
        effectiveTheme.decoration.borderRadius?.resolve(TextDirection.ltr) ??
        BorderRadius.circular(8);

    final card = Card(
      elevation: boxShadow != null && boxShadow.isNotEmpty
          ? boxShadow.first.blurRadius
          : 0,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: effectiveTheme.decoration,
        padding: effectiveTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.0,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      if (isNew || isExpired)
                        Wrap(
                          spacing: 6,
                          children: [
                            if (isNew) const _NewBadge(),
                            if (isExpired) const _ExpiredBadge(),
                          ],
                        ),
                      ExpandableTextWidget(
                        text: announcement.naslov,
                        style:
                            (effectiveTheme.textStyle ??
                                    theme.textTheme.titleLarge)
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: foreground,
                                ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (isBookmarked)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Icon(
                      Icons.bookmark,
                      color: foreground,
                      semanticLabel: locale.bookmarks,
                    ),
                  ),
                PopupMenuButton<_CardAction>(
                  icon: Icon(Icons.more_vert, color: foreground),
                  tooltip: locale.moreOptions,
                  onSelected: (action) => _onAction(context, ref, action),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _CardAction.bookmark,
                      child: ListTile(
                        leading: Icon(
                          isBookmarked
                              ? Icons.bookmark_remove
                              : Icons.bookmark_add_outlined,
                        ),
                        title: Text(
                          isBookmarked
                              ? locale.removeBookmark
                              : locale.bookmark,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _CardAction.share,
                      child: ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(locale.share),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _CardAction.copy,
                      child: ListTile(
                        leading: const Icon(Icons.copy),
                        title: Text(locale.copyText),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            DateRowWidget(
              creationDate: announcement.vrijemeKreiranja,
              expirationDate: announcement.vrijemeIsteka,
              style: theme.textTheme.bodySmall?.copyWith(
                color: foreground.withValues(alpha: 0.8),
              ),
            ),
            ExpandableTextWidget(
              text: announcement.sadrzaj,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              maxLines: 3,
            ),
            if (announcement.oglasPrilozi.isNotEmpty)
              AttachmentWidget(announcement: announcement, color: foreground),
            if (announcement.potpis != null)
              SignatureWidget(
                signature: announcement.potpis!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
    return isExpired ? Opacity(opacity: 0.6, child: card) : card;
  }
}

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge();

  @override
  Widget build(BuildContext context) {
    // Fixed colours, like the "new" badge, so it reads on the card in both
    // themes.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppLocalizations.of(context).expiredBadge,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    // Fixed amber: readable on the blue card in both themes.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppLocalizations.of(context).newBadge,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
