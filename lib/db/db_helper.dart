import 'dart:developer';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:story_app_preferences/model/model.dart';

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE DATA(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      description TEXT,
      imagePath TEXT
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('db_story.b', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createStory(StoryResult data) async {
    final db = await SqlHelper.db();

    final id = await db.insert('data', data.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllStory() async {
    final db = await SqlHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleStory(int id) async {
    final db = await SqlHelper.db();
    return db.query(
      'data',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  static Future<int> updateStory(StoryResult data, int id) async {
    final db = await SqlHelper.db();

    final result = await db.update(
      'data',
      data.toJson(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  static Future<void> deleteStory(int id) async {
    final db = await SqlHelper.db();
    try {
      await db.delete('data', where: 'id= ?', whereArgs: [id]);
    } catch (e) {
      log('Error -> $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchStory(String query) async {
    final db = await SqlHelper.db();
    return db.query(
      'data',
      where: 'description LIKE',
      whereArgs: List.generate(4, (_) => '%$query%'),
      orderBy: 'id',
    );
  }
}
