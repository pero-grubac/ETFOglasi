import 'dart:io';

import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  Future<String> download(String id, String directory, String fileName) async {
    try {
      final url = getAnnouncementDownload(id);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      String filePath = getUniqueFilePath(path.join(directory, fileName));

      final file = File(filePath);
      final parentDir = Directory(path.dirname(filePath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  String getUniqueFilePath(String basePath) {
    int count = 1;
    String filePath = basePath;
    while (File(filePath).existsSync()) {
      final extension = path.extension(basePath);
      final nameWithoutExtension = path.basenameWithoutExtension(basePath);
      final dir = path.dirname(basePath);
      filePath = path.join(dir, '$nameWithoutExtension($count)$extension');
      count++;
    }
    return filePath;
  }
}
