import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/schedule/data/model/dummy_data.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';

class ScheduleService {
  final ApiService service;

  ScheduleService({ApiService? apiService})
      : service = apiService ?? ApiService();

  Future<Schedule> fetchSchedule(String url) async {
    /*return await service.fetchData<Schedule>(
      url: url,
      fromJson: (json) {
        final List<dynamic> data = json;
        return _transformData(data);
      },
    );*/
    return _transformData(dummyData);
  }

  Schedule _transformData(List<dynamic> data) {
    final monday = <(String, String?)>[];
    final tuesday = <(String, String?)>[];
    final wednesday = <(String, String?)>[];
    final thursday = <(String, String?)>[];
    final friday = <(String, String?)>[];

    for (final row in data) {
      if (row == null || row.isEmpty) continue;
      final List<dynamic> items = row;

      final time = items[0] as String?;

      if (time == null) continue;

      final subjects = items.sublist(1, 6); // samo pon-pet

      if (subjects.length >= 5) {
        monday.add((time, subjects[0] as String?));
        tuesday.add((time, subjects[1] as String?));
        wednesday.add((time, subjects[2] as String?));
        thursday.add((time, subjects[3] as String?));
        friday.add((time, subjects[4] as String?));
      }
    }

    final schedule = Schedule(
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
    );
    schedule.sort();
    return schedule;
  }
}
