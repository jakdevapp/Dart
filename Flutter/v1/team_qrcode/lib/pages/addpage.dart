import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:team_qrcode/api/restapi.dart';
import 'package:team_qrcode/model/model.dart';
import 'package:team_qrcode/pages/roomlistpage.dart';
import 'package:team_qrcode/database/sqlitedb.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String qrcodeText;
  Room room = Room();
  RoomAPI roomAPI = RoomAPI();
  SqlDatabase database = SqlDatabase();

  Future<void> scanRoomQR() async {
    String qrcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(qrcodeScanRes);
    } on PlatformException {
      qrcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      qrcodeText = qrcodeScanRes;
      saveRoomToDatabase();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RoomListPage(qrcodeText)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildListTileItem(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF1338BE),
          tooltip: 'Increment',
          child: Icon(Icons.meeting_room),
          onPressed: () => scanRoomQR()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildListTileItem() {
    return FutureBuilder(
      future: database.readRooms(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data == null ? 0 : snapshot.data.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Room ID : ${snapshot.data[index].roomid}'),
                    trailing: IconButton(
                        icon: Icon(Icons.description),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoomListPage(
                                      snapshot.data[index].roomid)));
                        }),
                  ),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  saveRoomToDatabase() {
    room.roomid = qrcodeText;
    room = Room(roomid: room.roomid);
    database.createRoom(room);

    roomAPI.createRoomAPI(room).then((value) async => print(value));
  }
}
