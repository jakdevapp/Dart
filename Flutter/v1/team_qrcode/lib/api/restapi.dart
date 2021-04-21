import 'dart:io';

import 'package:dio/dio.dart';
import 'package:team_qrcode/model/model.dart';
import 'package:team_qrcode/utils/utils.dart';

String baseUrl = Utils.baseURL;

class RoomAPI {
  Future<Null> createRoomAPI(Room data) async {
    try {
      Map<String, dynamic> map = Map();
      map['roomid'] = data.roomid;

      FormData formData = FormData.fromMap(map);
      await Dio().post('$baseUrl/roomapi/', data: formData).then((value) {
        print(value);
      });

    } catch (e) {
      print(e);
      return null;
    }
  }
}

class AssetAPI {
  Future<Null> createAssetAPI(Asset data) async {
    try {
      
      
      Map<String, dynamic> map = Map();
      map['datetimestamp'] = data.datetimestamp;
      map['roomid'] = data.roomid;
      map['assetid'] = data.assetid;
      map['ownerid'] = data.ownerid;
      map['title'] = data.title;
      map['detail'] = data.detail;
      map['damage'] = data.damage;
      if (data.damage == true){
        print(data.damage);
        final photoFileName = File(data.photo).path.split('/').last;
        map['photo'] = await MultipartFile.fromFile(
          File(data.photo)?.path,
          filename: photoFileName
        );
      }
      map['damagedetail'] = data.damagedetail ;

      FormData formData = FormData.fromMap(map);
      await Dio().post('$baseUrl/assetapi/', data: formData).then((value) {
        print(value);
      });

    } catch (e) {
      print(e);
      return null;
    }
  }
}