import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart' as sql_api;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Future<sql_api.Database>? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Opens the database once; concurrent callers share the same future.
  Future<sql_api.Database> getDatabase() {
    return _database ??= _open();
  }

  Future<sql_api.Database> _open() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'etf.db'),
      onCreate: (db, version) {
        return db.transaction((tr) async {
          await tr.execute('''
            CREATE TABLE ${Schedule.dbName}(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER
            )
            ''');

          await tr.execute('''
            CREATE TABLE ${Announcement.dbName}(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
            )
            ''');

          await tr.execute('''
            CREATE TABLE ${Announcement.seenDbName}(
            id TEXT PRIMARY KEY,
            ids TEXT NOT NULL
            )
            ''');
        });
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
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE ${Schedule.dbName} ADD COLUMN updated_at INTEGER',
          );
          await db.update(Schedule.dbName, {
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE ${Announcement.seenDbName}(
              id TEXT PRIMARY KEY,
              ids TEXT NOT NULL
            )
          ''');
        }
      },
      version: 4,
    );
  }

  Future<void> closeDatabase() async {
    final database = _database;
    if (database != null) {
      _database = null;
      await (await database).close();
    }
  }
}
