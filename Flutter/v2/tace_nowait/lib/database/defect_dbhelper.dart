import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/model/defect.dart';

class DefectDBHelper {
  static Database _db;
  static const String TABLE = 'Defects';
  static const String ID = 'id';
  static const String PROJECTNAME = 'projectname';
  static const String NAME = 'name';
  static const String DETAIL = 'detail';
  static const String LOCATION = 'location';
  static const String CHECKER = 'checker';
  static const String UPLOADED = 'uploaded';

  static const String DB_NAME = 'db2.sqlite3';

  Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE (
        $ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $PROJECTNAME TEXT,
        $NAME TEXT,
        $DETAIL TEXT,
        $LOCATION TEXT,
        $CHECKER TEXT,
        $UPLOADED INTEGER
      )''');
  }

  Future<Defect> createDefect(Defect dfselect) async {
    await deleteAllDefect();
    var dbClient = await db;
    dfselect.id = await dbClient.insert(TABLE, dfselect.toJson());
    return dfselect;
  }

  Future<List<Defect>> readDefects() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, PROJECTNAME, NAME, DETAIL, LOCATION, CHECKER, UPLOADED]);
    List<Defect> alldefects = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        alldefects.add(Defect.fromJson(maps[i]));
      }
    }
    print(maps);
    return alldefects;
  }

  Future<Defect> updateDefect(Defect dfselect) async {
    var dbClient = await db;
    dfselect.id = await dbClient.update(TABLE, dfselect.toJson(),
        where: 'id = ?', whereArgs: [dfselect.id]);
    return dfselect;
  }

  Future<int> deleteDefect(int idselect) async {
    var dbClient = await db;
    idselect =
        await dbClient.delete(TABLE, where: 'id = ?', whereArgs: [idselect]);
    return idselect;
  }

  Future<int> deleteAllDefect() async {
    var dbClient = await db;
    var result = await dbClient.delete(TABLE);
    return result;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}