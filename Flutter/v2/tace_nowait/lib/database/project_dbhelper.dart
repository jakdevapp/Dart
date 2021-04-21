import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/model/project.dart';

class ProjectDBHelper {
  static Database _db;
  static const String TABLE = 'Project';
  static const String ID = 'id';
  static const String PROJECTID = 'projectid';
  static const String NAME = 'name';
  static const String DETAIL = 'detail';

  static const String DB_NAME = 'db4.sqlite3';

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
        $PROJECTID TEXT,
        $NAME TEXT,
        $DETAIL TEXT
      )''');
  }

  Future<Project> createProject(Project pjselect) async {
    var dbClient = await db;
    pjselect.id = await dbClient.insert(TABLE, pjselect.toMap());
    return pjselect;
  }

  Future<List<Project>> readProjects() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, PROJECTID, NAME, DETAIL]);
    List<Project> allproject = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        allproject.add(Project.fromMap(maps[i]));
      }
    }
    print(maps);
    return allproject;
  }

  Future<Project> updateProject(Project pjselect) async {
    var dbClient = await db;
    pjselect.id = await dbClient.update(TABLE, pjselect.toMap(),
        where: 'id = ?', whereArgs: [pjselect.id]);
    return pjselect;
  }

  Future<int> deleteProject(int idselect) async {
    var dbClient = await db;
    idselect =
        await dbClient.delete(TABLE, where: 'id = ?', whereArgs: [idselect]);
    return idselect;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
