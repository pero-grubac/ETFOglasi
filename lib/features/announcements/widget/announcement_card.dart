import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/ui/theme/announcement_card_theme.dart';
import 'package:etf_oglasi/core/ui/widget/expandable_text_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/announcement_share.dart';
import 'package:etf_oglasi/features/announcements/widget/attachment_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/date_row_widget.dart';
import 'package:etf_oglasi/features/announcements/widget/signature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/gen/app_localizations.dart';

enum _CardAction { share, copy }

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isNew = false,
  });
  final Announcement announcement;

  /// Shows a "new" badge (announcement not seen before).
  final bool isNew;

  Future<void> _onAction(BuildContext context, _CardAction action) async {
    final locale = AppLocalizations.of(context);
    final text = announcementShareText(announcement, locale);
    switch (action) {
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
  Widget build(BuildContext context) {
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

    return Card(
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
                      if (isNew) const _NewBadge(),
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
                PopupMenuButton<_CardAction>(
                  icon: Icon(Icons.more_vert, color: foreground),
                  tooltip: locale.moreOptions,
                  onSelected: (action) => _onAction(context, action),
                  itemBuilder: (context) => [
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
