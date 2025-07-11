import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
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

            await tr.execute('''
            CREATE TABLE ${Announcement.dbName}(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
            )
            ''');
          },
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE ${Announcement.dbName}(
              id TEXT PRIMARY KEY,
              data TEXT NOT NULL
            )
          ''');
        }
      },
      version: 2,
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
