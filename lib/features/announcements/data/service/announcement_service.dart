import 'dart:io';

import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:http/http.dart' as http;

class AnnouncementService {
  final ApiService service;

  AnnouncementService({ApiService? apiService})
      : service = apiService ?? ApiService();

  Future<List<Announcement>> fetchAnnouncements(String url) async {
    return await service.fetchData<List<Announcement>>(
      url: url,
      fromJson: (json) {
        final List<dynamic> data = json;
        return data.map((item) => Announcement.fromJson(item)).toList();
      },
    );
  }

  Future<void> download(String id, {String? customPath}) async {
    final url = getAnnouncementDownload(id); // Replace with actual endpoint

    // Make the HTTP request to download the file
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    String filePath;
    if (customPath != null) {
      filePath = customPath;
    } else {
      return;
    }

    // Write the file to the chosen location
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
  }
}
