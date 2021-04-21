import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_qrcode/model/model.dart';
import 'package:team_qrcode/api/restapi.dart';
import 'package:team_qrcode/database/sqlitedb.dart';
import 'package:team_qrcode/pages/roomlistpage.dart';

class FormRoomPage extends StatefulWidget {
  final String roomQRCode;
  final String assetQRCode;

  FormRoomPage(this.roomQRCode, this.assetQRCode);

  @override
  _FormRoomPageState createState() => _FormRoomPageState();
}

class _FormRoomPageState extends State<FormRoomPage> {
  final _formKey = GlobalKey<FormState>();
  String stampDateTime;
  String stampDateTimeFormat;
  String roomQRCode;
  String assetQRCode;
  final ownidController = TextEditingController();
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  final damageController = TextEditingController();
  bool isVisible = false;
  File _image;
  final picker = ImagePicker();

  Asset asset = Asset();
  Room room = Room();

  AssetAPI assetAPI = AssetAPI();
  RoomAPI roomAPI = RoomAPI();

  List<Asset> assetList = List<Asset>();
  SqlDatabase database = SqlDatabase();

  @override
  void initState() {
    super.initState();
    roomQRCode = widget.roomQRCode;
    asset.roomid = roomQRCode;
    assetQRCode = widget.assetQRCode;
    asset.assetid = assetQRCode;
    stampDateTime = DateTime.now().toIso8601String();
    readAllAsset();
  }

  readAllAsset() async {
    var resBody;
    Response response = await Dio().get('$baseUrl/assetapi/$assetQRCode');
    if (mounted)
      setState(() {
        resBody = response.data;
      });

    var d1 = resBody[0]['ownerid'];
    var d2 = resBody[0]['detail'];

    setState(() {
      ownidController.text = d1;
      detailController.text = d2;
    });
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
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String date = stampDateTime.split('T').first;
    String time = stampDateTime.split('T').last;
    stampDateTimeFormat = date + ' ' + time.substring(0, 8);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Asset'),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Room ID : ${asset.roomid}'),
              SizedBox(height: 5),
              Text('Asset ID : ${asset.assetid}'),
              TextFormField(
                decoration: InputDecoration(labelText: 'Owner ID : '),
                controller: ownidController,
                validator: (value) =>
                    value.isEmpty ? 'คุณไม่ได้ระบุ owner ID' : null,
                //onSaved: (value) => setState(() => qrCode.detail = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Asset title : '),
                controller: titleController,
                validator: (value) =>
                    value.isEmpty ? 'คุณไม่ได้ระบุ title' : null,
                //onSaved: (value) => setState(() => qrCode.title = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Asset detail : '),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                controller: detailController,
                validator: (value) =>
                    value.isEmpty ? 'คุณไม่ได้ระบุ detail' : null,
                //onSaved: (value) => setState(() => qrCode.detail = value),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Checkbox(
                  value: isVisible,
                  onChanged: (value) {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                ),
                Text('Damage ?')
              ]),
              Visibility(
                  visible: isVisible,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Column(
                    children: [
                      FlatButton.icon(
                        color: Colors.blue,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Camera'),
                        onPressed: getImage,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Damage detail : '),
                        controller: damageController,
                        // validator: (value) =>
                        //     value.isEmpty ? 'คุณไม่ได้ระบุ owner ID' : null,
                        //onSaved: (value) => setState(() => qrCode.detail = value),
                      ),
                      _image == null
                          ? Text('No image selected.')
                          : Image.file(_image, width: 300, height: 600),
                    ],
                  )),
              RaisedButton(
                child: Text("OK"),
                onPressed: () {
                  saveAssetDatabase();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RoomListPage(asset.roomid)));
                },
              ),
              // Expanded / Row / Column must be inside Flex
              // direction: Axis.horizontal,
            ],
          )),
      resizeToAvoidBottomPadding: false,
    );
  }

  saveAssetDatabase() {
    var imgpath;
    _formKey.currentState.save();
    if (isVisible == true) {
      imgpath = _image.path;
    } else {
      imgpath = null;
    }
    asset = Asset(
        datetimestamp: stampDateTimeFormat,
        roomid: asset.roomid,
        assetid: asset.assetid,
        ownerid: ownidController.text,
        title: titleController.text,
        detail: detailController.text,
        photo: imgpath,
        damagedetail: damageController.text,
        damage: isVisible);
    database.createAsset(asset);
    _formKey.currentState.reset();
    assetAPI.createAssetAPI(asset).then((value) async => print(value));
  }
}
