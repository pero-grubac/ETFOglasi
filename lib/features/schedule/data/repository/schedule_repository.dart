import 'package:etf_oglasi/core/repository/database.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleRepository {
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
    final map = schedule.toMap()..['id'] = id;
    await db.insert(
      Schedule.dbName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
