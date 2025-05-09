import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';

class ScheduleService {
  final ApiService service;

  ScheduleService({required this.service});

  Future<Schedule> fetchSchedule(String url) async {
    return await service.fetchData<Schedule>(
      url: url,
      fromJson: (json) {
        final List<dynamic> data = json;
        return _transformData(data);
      },
    );
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
        final cleanSubjects = subjects.map((subject) {
          if (subject == null) return null;
          return (subject as String).replaceAll('<br /> --- <br />', '\n');
        }).toList();

        monday.add((time, cleanSubjects[0]));
        tuesday.add((time, cleanSubjects[1]));
        wednesday.add((time, cleanSubjects[2]));
        thursday.add((time, cleanSubjects[3]));
        friday.add((time, cleanSubjects[4]));
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
