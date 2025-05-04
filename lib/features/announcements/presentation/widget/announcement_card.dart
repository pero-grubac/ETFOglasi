import 'package:etf_oglasi/core/ui/widget/expandable_text_widget.dart';
import 'package:etf_oglasi/core/ui/widget/spaced_column.dart';
import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/attachment_widget.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/date_row_widget.dart';
import 'package:etf_oglasi/features/announcements/presentation/widget/signature_widget.dart';
import 'package:flutter/material.dart';

import 'package:etf_oglasi/core/ui/theme/announcement_card_theme.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final announcementCardTheme = theme.extension<AnnouncementCardTheme>();
    final effectiveTheme = announcementCardTheme ??
        AnnouncementCardTheme(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          textStyle: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );

    return Card(
      elevation: effectiveTheme.decoration.boxShadow!.isNotEmpty
          ? effectiveTheme.decoration.boxShadow!.first.blurRadius
          : 0,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveTheme.decoration.borderRadius as BorderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: effectiveTheme.decoration,
        padding: effectiveTheme.padding,
        child: SpacedColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.0,
          children: [
            ExpandableTextWidget(
              text: announcement.naslov,
              style: effectiveTheme.textStyle ??
                  theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
            DateRowWidget(
              creationDate: announcement.vrijemeKreiranja,
              expirationDate: announcement.vrijemeIsteka,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            ExpandableTextWidget(
              text: announcement.sadrzaj,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
            ),
            if (announcement.oglasPrilozi.isNotEmpty)
              AttachmentWidget(announcement: announcement),
            if (announcement.potpis != null)
              SignatureWidget(
                signature: announcement.potpis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
