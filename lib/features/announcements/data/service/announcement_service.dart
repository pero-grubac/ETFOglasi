import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';

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
}
