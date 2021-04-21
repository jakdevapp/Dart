import 'package:dio/dio.dart';
import 'package:tace_nowait/database/defect_dbhelper.dart';
import 'package:tace_nowait/model/defect.dart';
import 'package:tace_nowait/util/util.dart';

class DefectAPI {  
  String baseUrl = Utils.baseURL;

  Future<List<Defect>> getAllDefects() async {
    Response response = await Dio().get('$baseUrl/defectapi');

    return (response.data as List).map((defect) {
      print('Inserting $defect');
      DefectDBHelper().createDefect(Defect.fromJson(defect));
    }).toList();
  }

  Future<Null> updateStatusDefect(int id) async {
    Map<String, dynamic> map = Map();
    map['uploaded'] = 1;

    FormData formData = FormData.fromMap(map);
    await Dio().patch('$baseUrl/defectapi/$id', data: formData).then((value) {
      print(value);
    });
  }

  Future deleteDefect(int id) async {
    Map<String, dynamic> map = Map();
    map['id'] = id;

    FormData formData = FormData.fromMap(map);
    await Dio().delete('$baseUrl/defectapi/$id}', data: formData).then((value) {
      print(value);
    });
  }
}