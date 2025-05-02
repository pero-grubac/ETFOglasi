import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:flutter/material.dart';

import 'package:etf_oglasi/core/ui/theme/announcement_card_theme.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatefulWidget {
  const AnnouncementCard({super.key, required this.announcement});
  final Announcement announcement;

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  bool _isExpanded = false;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                widget.announcement.naslov,
                style: effectiveTheme.textStyle ??
                    theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: _isExpanded ? null : 2,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12), // Spacing between title and dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kreirano: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.announcement.vrijemeKreiranja)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                Text(
                  'Istek: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.announcement.vrijemeIsteka)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 12), // Spacing between dates and content
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                widget.announcement.sadrzaj,
                style: theme.textTheme.bodyMedium,
                maxLines: _isExpanded ? null : 3,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (widget.announcement.oglasPrilozi.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.attach_file,
                        size: 16, color: theme.colorScheme.onSurface),
                    Text(
                      'PRILOG',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.announcement.potpis != null) ...[
              const SizedBox(height: 12), // Spacing before signature
              Text(
                'Potpis: ${widget.announcement.potpis}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
