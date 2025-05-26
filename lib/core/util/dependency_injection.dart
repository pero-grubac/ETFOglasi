import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api/api_service.dart';
import 'package:etf_oglasi/core/service/api/major_service.dart';
import 'package:etf_oglasi/core/service/api/room_service.dart';
import 'package:etf_oglasi/core/service/api/study_program_service.dart';
import 'package:etf_oglasi/core/service/api/teacher_service.dart';
import 'package:etf_oglasi/features/announcements/data/service/announcement_service.dart';
import 'package:etf_oglasi/features/schedule/data/repository/schedule_repository.dart';
import 'package:etf_oglasi/features/schedule/data/service/schedule_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Services
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(service: ref.read(apiServiceProvider));
});

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(service: ref.read(apiServiceProvider));
});

final teacherServiceProvider = Provider<TeacherService>((ref) {
  return TeacherService(service: ref.read(apiServiceProvider));
});

final studyProgramProvider = Provider<StudyProgramService>((ref) {
  return StudyProgramService(service: ref.read(apiServiceProvider));
});

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService(service: ref.read(apiServiceProvider));
});

final majorServiceProvider = Provider<MajorService>((ref) {
  return MajorService(service: ref.read(apiServiceProvider));
});

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(dbHelper: ref.read(databaseHelperProvider));
});
