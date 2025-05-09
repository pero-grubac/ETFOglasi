import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

class StudyProgramService {
  final ApiService service;

  StudyProgramService({required this.service});

  Future<List<StudyProgram>> fetchTeachers() async {
    return await service.fetchData<List<StudyProgram>>(
      url: getStudyProgramsUrl(),
      fromJson: (json) {
        final List<dynamic> data = json;
        return data.map((item) => StudyProgram.fromJson(item)).toList();
      },
    );
  }
}
