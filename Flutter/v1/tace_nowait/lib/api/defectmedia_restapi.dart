import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tace_nowait/model/defectmedia.dart';
import 'package:tace_nowait/util/util.dart';

class DefectMediaAPI {
  var baseUrl = Utils.baseURL;
  var res;

  Future<Null> createDefectMedia(DefectMedia data) async {
    try {
      final photoFileName = File(data.photo).path.split('/').last;
      final drawphotoFileName = File(data.drawphoto).path.split('/').last;
      final audioFileName = File(data.audio).path.split('/').last;

      Map<String, dynamic> map = Map();
      map['photo'] = await MultipartFile.fromFile(
          File(data.photo).path,
          filename: photoFileName);

      map['drawphoto'] = await MultipartFile.fromFile(
          File(data.drawphoto).path,
          filename: drawphotoFileName);

      map['audio'] = await MultipartFile.fromFile(
          File(data.audio).path,
          filename: audioFileName);
      
      map['projectname'] = data.projectname;
      map['name'] = data.name;
      map['detail'] = data.detail;
      map['location'] = data.location;
      map['checker'] = data.checker;

      FormData formData = FormData.fromMap(map);
      await Dio().post('$baseUrl/defectmediaapi/', data: formData).then((value) {
        print(value);
      });

    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<DefectMedia>> retrieveProfiles() async {
    // final response = await client.get("$baseUrl/api/");
    // if (response.statusCode == 200) {
    //   return profileFromJson(response.body);
    // } else {
    //   return null;
    // }
  }

  Future<Null> updateProfile(DefectMedia data) async {
    // final response = await client.put(
    //   "$baseUrl/api/${data.id}",
    //   headers: {"content-type": "application/json"},
    //   body: profileToJson(data),
    // );
    // if (response.statusCode == 200) {
    //   return true;
    // } else {
    //   return false;
    // }
  }
}