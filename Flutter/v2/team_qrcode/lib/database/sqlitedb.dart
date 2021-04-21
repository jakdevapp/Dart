import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:team_qrcode/model/model.dart';

class SqlDatabase {
  Database _database;
  static const String DB_NAME = 'asset.sqlite3';
  static const String TABLE = 'Assets';
  static const String ID = 'id';
  static const String DATETIMESTAMP = 'datetimestamp';
  static const String ROOMID = 'roomid';
  static const String ASSETID = 'assetid';
  static const String OWNERID = 'ownerid';
  static const String TITLE = 'title';
  static const String DETAIL = 'detail';
  static const String PHOTO = 'photo';
  static const String DAMAGEDETAIL = 'damagedetail';
  static const String DAMAGE = 'damage';

  // --------------------- Room --------------------- //
  Future initDB() async {
    if (_database == null) {
      _database = await openDatabase(
          join(await getDatabasesPath(), 'room.sqlite3'),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(         
          '''CREATE TABLE Rooms(
             $ID INTEGER PRIMARY KEY AUTOINCREMENT,
             $ROOMID TEXT
          )''');
        }
      );
    }
  }

  Future<int> createRoom(Room room) async {
    await initDB();
    return await _database.insert('Rooms', room.toMap());
  }

  Future<List<Room>> readRooms() async {
    await initDB();
    List<Map<String, dynamic>> maps = await _database.query('Rooms');
    List<Map<String, dynamic>> myList = [];
    maps.forEach((item) { 
      var i = myList.indexWhere((x) => x[ROOMID] == item[ROOMID]);
      if (i <= -1) {
        myList.add({ID:item[ID],ROOMID:item[ROOMID]});
      }
    });
    maps = myList;
    print(maps);
    return List.generate(maps.length, (i) {
      return Room(
          id: maps[i][ID],
          roomid: maps[i][ROOMID]
      );
    });
  }

  Future<int> updateRoom(Room room) async {
    await initDB();    
    return await _database.update('Rooms', room.toMap(),
        where: "id = ?", whereArgs: [room.id]);
  }

  Future<void> deleteRoom(int id) async {
    await initDB();
    await _database.delete(
      'Rooms',
        where: "id = ?", whereArgs: [id]
    );
  }

  // --------------------- Asset --------------------- //
  Database _db;
  Future openDb() async {
    if (_db == null) {
      _db = await openDatabase(
          join(await getDatabasesPath(), DB_NAME),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(         
          '''CREATE TABLE $TABLE(
             $ID INTEGER PRIMARY KEY AUTOINCREMENT,
             $DATETIMESTAMP TEXT,
             $ROOMID TEXT,
             $ASSETID TEXT,
             $OWNERID TEXT,
             $TITLE TEXT,
             $DETAIL TEXT,
             $PHOTO TEXT,
             $DAMAGEDETAIL TEXT,
             $DAMAGE INTEGER
          )''');
        }
      );
    }
  }

  Future<int> createAsset(Asset asset) async {
    await openDb();
    return await _db.insert(TABLE, asset.toMap());
  }

  Future<List<Asset>> readAssets() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(TABLE);
    print(maps);
    return List.generate(maps.length, (i) {
      return Asset(
          id: maps[i][ID],
          datetimestamp: maps[i][DATETIMESTAMP],
          roomid: maps[i][ROOMID],
          assetid: maps[i][ASSETID],
          ownerid: maps[i][OWNERID],
          title: maps[i][TITLE],
          detail: maps[i][DETAIL],
          photo: maps[i][PHOTO],
          damagedetail: maps[i][DAMAGEDETAIL],
          damage: maps[i][DAMAGE] == 1
      );
    });
  }

  Future<List<Asset>> readAssetByRoom(Asset asset) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(TABLE, where: "$ROOMID = ?", whereArgs: [asset.roomid]);
    return List.generate(maps.length, (i) {
      return Asset(
          id: maps[i][ID],
          datetimestamp: maps[i][DATETIMESTAMP],
          roomid: maps[i][ROOMID],
          assetid: maps[i][ASSETID],
          ownerid: maps[i][OWNERID],
          title: maps[i][TITLE],
          detail: maps[i][DETAIL],
          photo: maps[i][PHOTO],
          damagedetail: maps[i][DAMAGEDETAIL],
          damage: maps[i][DAMAGE] == 1
      );
    });
  }

  Future<int> updateAsset(Asset asset) async {
    await openDb();    
    return await _db.update(TABLE, asset.toMap(),
        where: "id = ?", whereArgs: [asset.id]);
  }

  Future<void> deleteAsset(int id) async {
    await openDb();
    await _db.delete(
      TABLE,
        where: "id = ?", whereArgs: [id]
    );
  }
}