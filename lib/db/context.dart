import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/model/user.dart';

class DBContext {
  static final DBContext instance = DBContext._init();
  static Database? _database;

  DBContext._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("myapp.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, fileName);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future _createDB(Database db, int version) async {
    const String notNull = "NOT NULL";
    const String typeText = "TEXT";
    const String typeInt = "INT";
    const String pk = "INTEGER PRIMARY KEY AUTOINCREMENT";

    await db.execute('''
      CREATE TABLE $userTable (
          ${UserField.id} $pk,
          ${UserField.name} $typeText $notNull,
          ${UserField.level} $typeInt $notNull
        )
     ''');
  }

  Future<User> create(User user) async {
    final db = await instance.database;
    final id = await db.insert(userTable, user.toJson());
    return user.copy(id: id);
  }

  Future<User> getbyId(int id) async {
    final db = await instance.database;
    final result = await db.query(userTable,
        columns: UserField.values,
        where: "${UserField.id} = ?",
        whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<User>> getall() async {
    final db = await instance.database;
    final orderBy = '${UserField.id} ASC';
    final result = await db.query(userTable, orderBy: orderBy);
    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<int> update(User user) async {
    final db = await instance.database;
    return db.update(userTable, user.toJson(),
        where: '${UserField.id} = ?', whereArgs: [user.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(userTable, where: '${UserField.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
