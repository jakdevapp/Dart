import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tace_nowait/model/profile.dart';
import 'package:tace_nowait/util/util.dart';

class ProfileAPI {
  var baseUrl = Utils.baseURL;

  Future<Null> createProfile(Profile data) async {
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

      map['projectid'] = data.projectid;
      map['projectname'] = data.projectname;
      map['content'] = data.content;

      map['audio'] = await MultipartFile.fromFile(
          File(data.audio).path,
          filename: audioFileName);

      map['datetimestamp'] = data.datetimestamp;
      map['uploaded'] = true;

      FormData formData = FormData.fromMap(map);
      await Dio().post('$baseUrl/api/', data: formData).then((value) {
        print(value);
      });

    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Profile>> retrieveProfiles() async {
    // final response = await client.get("$baseUrl/api/");
    // if (response.statusCode == 200) {
    //   return profileFromJson(response.body);
    // } else {
    //   return null;
    // }
  }

  Future<Null> updateProfile(Profile data) async {
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

  Future<Null> deleteProfile(int id) async {
    // final response = await client.delete(
    //   "$baseUrl/api/$id",
    //   headers: {"content-type": "application/json"},
    // );
    // if (response.statusCode == 200) {
    //   return true;
    // } else {
    //   return false;
    // }
  }
}
