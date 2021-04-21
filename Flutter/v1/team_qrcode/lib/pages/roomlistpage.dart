import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:team_qrcode/model/model.dart';
import 'package:team_qrcode/database/sqlitedb.dart';
import 'package:team_qrcode/pages/formroompage.dart';

class RoomListPage extends StatefulWidget {
  final String roomQRCode;
  RoomListPage(this.roomQRCode);

  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  String roomQRCode;
  String assetQRCode;
  var image;

  Asset asset = Asset();
  Room room = Room();

  List<Asset> assetList = List<Asset>();
  SqlDatabase database = SqlDatabase();

  @override
  void initState() {
    super.initState();
    roomQRCode = widget.roomQRCode;
    asset.roomid = roomQRCode;
  }

  Future<void> scanAssetQR() async {
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
      assetQRCode = qrcodeScanRes;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FormRoomPage(roomQRCode, assetQRCode)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ID : ${asset.roomid}'),
      ),
      body: buildListTileItem(),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF1338BE),
          tooltip: 'Increment',
          child: Icon(Icons.qr_code_sharp),
          onPressed: () => scanAssetQR()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildListTileItem() {
    return FutureBuilder(
      future: database.readAssetByRoom(asset),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data == null ? 0 : snapshot.data.length,
              itemBuilder: (context, index) {
                if (snapshot.data[index].photo != null){
                  image = Image.file(File(snapshot.data[index].photo));
                }else{
                  image = Image.asset('images/nodamage.png');
                }
                return Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    leading: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: 100, maxHeight: 100),
                      child: image,
                    ),
                    title: Text('Room ID : ${snapshot.data[index].roomid}'),
                    subtitle: Text('Asset ID : ${snapshot.data[index].assetid}'
                              '\n'
                              'Title : ${snapshot.data[index].title}'
                              '\n'
                              'Detail : ${snapshot.data[index].detail}'
                              '\n'
                    ),
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
}
