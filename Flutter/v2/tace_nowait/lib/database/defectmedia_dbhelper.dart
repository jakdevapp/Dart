import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/model/defectmedia.dart';

class DefectMediaDBHelper {
  static Database _db;
  static const String TABLE = 'DefectMedia';
  static const String ID = 'id';
  static const String PHOTOPATH = 'photo';
  static const String DRAWPATH = 'drawphoto';
  static const String PROJECTNAME = 'projectname';
  static const String NAME = 'name';
  static const String DETAIL = 'detail';
  static const String LOCATION = 'location';
  static const String CHECKER = 'checker';
  static const String AUDIOPATH = 'audio';

  static const String DB_NAME = 'db3.sqlite3';

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
        $PHOTOPATH TEXT,
        $DRAWPATH TEXT,
        $PROJECTNAME TEXT,
        $NAME TEXT,
        $DETAIL TEXT,
        $LOCATION TEXT,
        $CHECKER TEXT,
        $AUDIOPATH TEXT
      )''');
  }

  Future<DefectMedia> createDefectMedia(DefectMedia dfmselect) async {
    var dbClient = await db;
    dfmselect.id = await dbClient.insert(TABLE, dfmselect.toMap());
    return dfmselect;
  }

  Future<List<DefectMedia>> readDefectMedias() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, PHOTOPATH, DRAWPATH, PROJECTNAME, NAME, DETAIL, LOCATION, CHECKER, AUDIOPATH]);
    List<DefectMedia> dfm = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        dfm.add(DefectMedia.fromMap(maps[i]));
      }
    }
    print(maps);
    return dfm;
  }

  Future<DefectMedia> updateDefectMedia(DefectMedia dfmselect) async {
    var dbClient = await db;
    dfmselect.id = await dbClient.update(TABLE, dfmselect.toMap(),
        where: 'id = ?', whereArgs: [dfmselect.id]);
    return dfmselect;
  }

  Future<int> deleteDefectMedia(int idselect) async {
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