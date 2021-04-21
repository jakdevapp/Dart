import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/model/profile.dart';

class ProfileDBHelper {
  static Database _db;
  static const String TABLE = 'Profiles';
  static const String ID = 'id';
  static const String PHOTOPATH = 'photo';
  static const String DRAWPATH = 'drawphoto';
  static const String PROJECTID = 'projectid';
  static const String PROJECTNAME = 'projectname';
  static const String CONTENT = 'content';
  static const String AUDIOPATH = 'audio';
  static const String DATETIMESTAMP = 'datetimestamp';
  static const String UPLOADED = 'uploaded';

  static const String DB_NAME = 'db.sqlite3';

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
        $PROJECTID TEXT,
        $PROJECTNAME TEXT,
        $CONTENT TEXT,
        $AUDIOPATH TEXT,
        $DATETIMESTAMP DATETIME,
        $UPLOADED INTEGER
      )''');
  }

  Future<Profile> createProfile(Profile pfselect) async {
    var dbClient = await db;
    pfselect.id = await dbClient.insert(TABLE, pfselect.toMap());
    return pfselect;
  }

  Future<List<Profile>> readProfiles() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,
        columns: [ID, PHOTOPATH, DRAWPATH, PROJECTID, PROJECTNAME, CONTENT, AUDIOPATH, DATETIMESTAMP, UPLOADED]);
    List<Profile> allphoto = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        allphoto.add(Profile.fromMap(maps[i]));
      }
    }
    print(maps);
    return allphoto;
  }

  Future<Profile> updateProfile(Profile pfselect) async {
    var dbClient = await db;
    pfselect.id = await dbClient.update(TABLE, pfselect.toMap(),
        where: 'id = ?', whereArgs: [pfselect.id]);
    return pfselect;
  }

  Future<int> deleteProfile(int idselect) async {
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
