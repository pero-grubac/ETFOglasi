import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';

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
    final List<ScheduleEntry> monday = [];
    final List<ScheduleEntry> tuesday = [];
    final List<ScheduleEntry> wednesday = [];
    final List<ScheduleEntry> thursday = [];
    final List<ScheduleEntry> friday = [];

    for (final row in data) {
      if (row == null || row.isEmpty) continue;
      final List<dynamic> items = row;

      final time = items[0] as String?;
      if (time == null) continue;
      final timeParts = time.split(':');
      if (timeParts.length != 2) continue;
      final hour = int.tryParse(timeParts[0]);
      if (hour == null) continue;
      if (hour < 8 || hour >= 22) continue;

      final subjects = items.sublist(1, 6); // samo pon-pet

      if (subjects.length >= 5) {
        final cleanSubjects = subjects.map((subject) {
          if (subject == null) return null;
          if (subject is String) {
            if (subject.contains('<br />')) {
              return subject.replaceAll('<br /> --- <br />', '\n');
            }
            return subject;
          }
          return null;
        }).toList();

        monday.add(ScheduleEntry(time: time, subject: cleanSubjects[0]));
        tuesday.add(ScheduleEntry(time: time, subject: cleanSubjects[1]));
        wednesday.add(ScheduleEntry(time: time, subject: cleanSubjects[2]));
        thursday.add(ScheduleEntry(time: time, subject: cleanSubjects[3]));
        friday.add(ScheduleEntry(time: time, subject: cleanSubjects[4]));
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
