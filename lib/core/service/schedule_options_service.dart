import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

/// Fetches the lists used to pick a schedule (teachers, rooms, programs, years).
class ScheduleOptionsService {
  final ApiService service;

  ScheduleOptionsService({required this.service});

  Future<List<Teacher>> fetchTeachers() =>
      service.fetchList(url: getTeachersUrl(), fromJson: Teacher.fromJson);

  Future<List<Room>> fetchRooms() =>
      service.fetchList(url: getRoomUrl(), fromJson: Room.fromJson);

  Future<List<StudyProgram>> fetchStudyPrograms() => service.fetchList(
    url: getStudyProgramsUrl(),
    fromJson: StudyProgram.fromJson,
  );

  Future<List<Major>> fetchMajors(String studyProgramId) => service.fetchList(
    url: getMajorsUrl(studyProgramId),
    fromJson: Major.fromJson,
  );
}
