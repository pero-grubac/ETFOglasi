import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/major_service.dart';
import 'package:etf_oglasi/core/service/room_service.dart';
import 'package:etf_oglasi/core/service/study_program_service.dart';
import 'package:etf_oglasi/core/service/teacher_service.dart';
import 'package:etf_oglasi/features/announcements/data/service/announcement_service.dart';
import 'package:etf_oglasi/features/schedule/data/service/schedule_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void setUpLocator() {
  getIt.registerLazySingleton<ApiService>(() => ApiService());

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
  getIt.registerLazySingleton<ScheduleService>(
    () => ScheduleService(service: getIt<ApiService>()),
  );
}
