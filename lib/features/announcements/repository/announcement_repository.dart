import 'dart:convert';

import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/repository/database.dart';
import 'package:sqflite/sqflite.dart';

class AnnouncementRepository {
  final DatabaseHelper dbHelper;

  AnnouncementRepository({required this.dbHelper});

  Future<List<Announcement>?> findAnnouncementsById(String id) async {
    final db = await dbHelper.getDatabase();
    final result = await db.query(
      Announcement.dbName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    final jsonString = result.first['data'] as String;

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<Announcement> announcements = jsonList
        .map((a) => Announcement.fromJson(a as Map<String, dynamic>))
        .toList();

    return announcements;
  }

  Future<void> saveAnnouncements(
    String id,
    List<Announcement> announcements,
  ) async {
    final db = await dbHelper.getDatabase();
    final jsonString = jsonEncode(
      announcements.map((e) => e.toJson()).toList(),
    );
    await db.insert(Announcement.dbName, {
      'id': id,
      'data': jsonString,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Ids of the announcements the user has already seen on the board, or
  /// `null` when the board was never opened.
  Future<Set<int>?> findSeenIds(String id) async {
    final db = await dbHelper.getDatabase();
    final result = await db.query(
      Announcement.seenDbName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    final List<dynamic> ids = jsonDecode(result.first['ids'] as String);
    return ids.cast<int>().toSet();
  }

  Future<void> saveSeenIds(String id, Set<int> ids) async {
    final db = await dbHelper.getDatabase();
    await db.insert(Announcement.seenDbName, {
      'id': id,
      'ids': jsonEncode(ids.toList()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
