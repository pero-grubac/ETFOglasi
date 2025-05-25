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
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void setUpLocator() {
  // core
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // service
  getIt.registerLazySingleton<MajorService>(
    () => MajorService(service: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<RoomService>(
    () => RoomService(service: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<StudyProgramService>(
    () => StudyProgramService(service: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<TeacherService>(
    () => TeacherService(service: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AnnouncementService>(
    () => AnnouncementService(service: getIt<ApiService>()),
  );
}

// Core service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Services
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(service: ref.read(apiServiceProvider));
});

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(dbHelper: ref.read(databaseHelperProvider));
});
