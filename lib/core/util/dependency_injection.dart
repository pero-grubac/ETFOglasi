import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/service/schedule_options_service.dart';
import 'package:etf_oglasi/core/service/update_service.dart';
import 'package:etf_oglasi/features/announcements/repository/announcement_repository.dart';
import 'package:etf_oglasi/features/announcements/repository/bookmark_repository.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:etf_oglasi/features/schedule/repository/schedule_repository.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Core service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Services
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(service: ref.watch(apiServiceProvider));
});

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(service: ref.watch(apiServiceProvider));
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(service: ref.watch(apiServiceProvider));
});

final errorLogProvider = Provider<ErrorLog>((ref) => errorLog);

/// The installed app version, e.g. `1.1.0`.
final appVersionProvider = FutureProvider<String>((ref) async {
  return (await PackageInfo.fromPlatform()).version;
}, retry: (_, _) => null);

final scheduleOptionsServiceProvider = Provider<ScheduleOptionsService>((ref) {
  return ScheduleOptionsService(service: ref.watch(apiServiceProvider));
});

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(dbHelper: ref.watch(databaseHelperProvider));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(dbHelper: ref.watch(databaseHelperProvider));
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository(dbHelper: ref.watch(databaseHelperProvider));
});
