import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleRepository {
  /// Cached schedules not refreshed for this long are deleted.
  static const Duration maxAge = Duration(days: 60);

  final DatabaseHelper dbHelper;

  ScheduleRepository({required this.dbHelper});

  Future<Schedule?> findScheduleById(String id) async {
    final db = await dbHelper.getDatabase();
    final data = await db.query(
      Schedule.dbName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (data.isNotEmpty) {
      return Schedule.fromMap(data.first);
    } else {
      return null;
    }
  }

  Future<void> saveSchedule(String id, Schedule schedule) async {
    final db = await dbHelper.getDatabase();
    final now = DateTime.now();
    final map = schedule.toMap()
      ..['id'] = id
      ..['updated_at'] = now.millisecondsSinceEpoch;
    await db.insert(
      Schedule.dbName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Room schedules are stored per week, so old rows pile up otherwise.
    await db.delete(
      Schedule.dbName,
      where: 'updated_at < ?',
      whereArgs: [now.subtract(maxAge).millisecondsSinceEpoch],
    );
  }
}
