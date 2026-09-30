import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:intl/intl.dart';

import '../../../core/gen/app_localizations.dart';

/// Plain-text version of an announcement for sharing and copying.
String announcementShareText(
  Announcement announcement,
  AppLocalizations locale,
) {
  final format = DateFormat('dd.MM.yyyy HH:mm');
  return [
    announcement.naslov,
    '${locale.createdAt(date: format.format(announcement.vrijemeKreiranja))}'
        ' · ${locale.expiresAt(date: format.format(announcement.vrijemeIsteka))}',
    if (announcement.uvod?.trim().isNotEmpty ?? false)
      announcement.uvod!.trim(),
    announcement.sadrzaj.trim(),
    if (announcement.potpis != null)
      '${locale.signature}: ${announcement.potpis}',
  ].join('\n\n');
}
