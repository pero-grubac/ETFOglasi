import 'dart:typed_data';

import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

class AnnouncementService {
  final ApiService service;

  AnnouncementService({required this.service});

  Future<List<Announcement>> fetchAnnouncements(String url) {
    return service.fetchList(url: url, fromJson: Announcement.fromJson);
  }

  /// Downloads the attachment of the announcement with [announcementId].
  /// The API only exposes one download endpoint per announcement.
  Future<Uint8List> downloadAttachment(String announcementId) {
    return service.fetchBytes(getAnnouncementDownloadUrl(announcementId));
  }
}
