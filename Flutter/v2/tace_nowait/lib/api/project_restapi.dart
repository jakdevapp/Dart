import 'package:dio/dio.dart';
import 'package:tace_nowait/model/project.dart';
import 'package:tace_nowait/util/util.dart';

class ProjectAPI {
  var baseUrl = Utils.baseURL;
  Project project = Project();

  Future<List<Project>> getAllProjects() async {
    Response response = await Dio().get('$baseUrl/projectapi');
    return (response.data as List).map((project) {
      print('Fetching $project');
    }).toList();
  }
}