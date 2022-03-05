import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SQLHelper{
  //Creates the database table
  static Future<void> createTable(sql.Database database) async{
    await database.execute(""" CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  //create table method call
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'boxed.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      }
    );
  }

  //creates a new item
  static Future<int> createItem(String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': desc};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //Reads all items
  static Future<List<Map<String, dynamic>>> getItems() async{
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  //Updates item
  static Future<int> updateItem(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': desc,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('items',data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void>deleteItems(int id) async {
    final db = await SQLHelper.db();
    try{
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Something went wrong with deleting an item: $e');
    }
  }
}