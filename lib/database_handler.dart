import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Handler{
  static final _databaseName = "stats.db";
  static final _databaseVersion = 1;

  static final table1 ='battle_stats';
  static final table2 ='psn_stats';
  static final table3 ='xbox_stats';

  static final columnTag = 'tag';
  static final columnPlatform = 'platform';
  static final columnWins = 'wins';
  static final columnKills = 'kills';
  static final columnDeaths = 'deaths';
  static final columnDowns = 'downs';

  Handler._privateConstructor();
  static final Handler instance = Handler._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async{
    await db.execute('''
    CREATE TABLE $table1(
    $columnTag TEXT NOT NULL PRIMARY KEY,
    $columnPlatform TEXT NOT NULL,
    $columnWins INTEGER NOT NULL,
    $columnKills INTEGER NOT NULL,
    $columnDeaths INTEGER NOT NULL,
    $columnDowns INTEGER NOT NULL
    )''');
    await db.execute('''
    CREATE TABLE $table2(   
    $columnTag TEXT NOT NULL PRIMARY KEY,
    $columnPlatform TEXT NOT NULL,
    $columnWins INTEGER NOT NULL,
    $columnKills INTEGER NOT NULL,
    $columnDeaths INTEGER NOT NULL,
    $columnDowns INTEGER NOT NULL
    )''');
    await db.execute('''
    CREATE TABLE $table3(    
    $columnTag TEXT NOT NULL PRIMARY KEY,
    $columnPlatform TEXT NOT NULL,
    $columnWins INTEGER NOT NULL,
    $columnKills INTEGER NOT NULL,
    $columnDeaths INTEGER NOT NULL,
    $columnDowns INTEGER NOT NULL
    )''');
  }

  Future insert(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String tag, String table) async {
    Database db = await instance.database;
    String id = tag;
    return await db.query(table, where: '$columnTag = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    String id = row[columnTag];
    return await db.update(table, row, where: '$columnTag = ?', whereArgs: [id]);
  }

  Future<int> delete(String tag, String table) async {
    Database db = await instance.database;
    String id = tag;
    return await db.delete(table, where: '$columnTag = ?', whereArgs: [id]);
  }

  Future deleteAll(String table) async {
    Database db = await instance.database;
    return await db.delete(table);
  }

}