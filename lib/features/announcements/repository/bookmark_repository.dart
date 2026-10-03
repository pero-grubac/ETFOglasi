import 'dart:convert';

import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:sqflite/sqflite.dart';

/// Announcements the user saved. They are stored whole, so they stay after
/// they disappear from the board.
class BookmarkRepository {
  final DatabaseHelper dbHelper;

  BookmarkRepository({required this.dbHelper});

  /// Newest saved first.
  Future<List<Announcement>> findAll() async {
    final db = await dbHelper.getDatabase();
    final rows = await db.query(
      Announcement.bookmarkDbName,
      orderBy: 'saved_at DESC',
    );
    return [
      for (final row in rows)
        Announcement.fromJson(
          jsonDecode(row['data'] as String) as Map<String, dynamic>,
        ),
    ];
  }

  Future<void> save(Announcement announcement, DateTime savedAt) async {
    final db = await dbHelper.getDatabase();
    await db.insert(Announcement.bookmarkDbName, {
      'id': announcement.id,
      'data': jsonEncode(announcement.toJson()),
      'saved_at': savedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(int id) async {
    final db = await dbHelper.getDatabase();
    await db.delete(
      Announcement.bookmarkDbName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
