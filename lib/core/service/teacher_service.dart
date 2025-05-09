import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

class TeacherService {
  final ApiService service;

  TeacherService({required this.service});
  Future<List<Teacher>> fetchTeachers() async {
    return await service.fetchData<List<Teacher>>(
      url: getTeachersUrl(),
      fromJson: (json) {
        final List<dynamic> data = json;
        return data.map((item) => Teacher.fromJson(item)).toList();
      },
    );
  }
}
