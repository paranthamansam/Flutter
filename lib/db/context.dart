import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:myapp/model/history.dart';

class DBContext {
  static final DBContext instance = DBContext._init();
  static Database? _database;

  DBContext._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("feedhistory.db");
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const String notNull = "NOT NULL";
    const String typeText = "TEXT";
    const String pk = "INTEGER PRIMARY KEY AUTOINCREMENT";

    await db.execute('''
      CREATE TABLE $historyTable (
        ${HistoryField.id} $pk,
        ${HistoryField.start} $typeText $notNull,
        ${HistoryField.end} $typeText $notNull,
        ${HistoryField.duration} $typeText $notNull,
        ${HistoryField.category} $typeText $notNull
      )
    ''');
  }

  Future<History> create(History history) async {
    final db = await instance.database;
    final id = await db.insert(historyTable, history.toJson());
    return history.copy(id: id);
  }

  Future<List<History>> getAllHistory() async {
    final db = await instance.database;
    const orderBy = '${HistoryField.id} ASC';
    final result = await db.query(historyTable, orderBy: orderBy);
    return result.map((json) => History.fromJson(json)).toList();
  }

  Future<History> getHistoryById(int id) async {
    final db = await instance.database;
    final result =
        await db.query(historyTable, where: 'id = ?', whereArgs: [id]);
    return result.map((json) => History.fromJson(json)).first;
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db
        .delete(historyTable, where: '${HistoryField.id} = ?', whereArgs: [id]);
  }

  Future<int> update(History history) async {
    final db = await instance.database;
    return db.update(historyTable, history.toJson(),
        where: '${HistoryField.id} = ?', whereArgs: [history.id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
