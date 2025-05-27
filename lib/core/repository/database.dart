import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart' as sql_api;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static sql_api.Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();
  Future<sql_api.Database> getDatabase() async {
    if (_database != null) return _database!;
    final dbPath = await sql.getDatabasesPath();
    _database = await sql.openDatabase(
      path.join(dbPath, 'etf.db'),
      onCreate: (db, version) {
        return db.transaction(
          (tr) async {
            await tr.execute('''
            CREATE TABLE ${Schedule.dbName}(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
            )
            ''');
          },
        );
      },
      version: 1,
    );
    return _database!;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
