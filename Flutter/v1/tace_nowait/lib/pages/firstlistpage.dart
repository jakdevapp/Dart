import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tace_nowait/api/defect_restapi.dart';
import 'package:tace_nowait/api/project_restapi.dart';
import 'package:tace_nowait/database/defect_dbhelper.dart';
import 'package:tace_nowait/model/project.dart';
import 'package:tace_nowait/pages/photodraw2.dart';
import 'package:tace_nowait/util/util.dart';

class FirstListPage extends StatefulWidget {
  @override
  _FirstListPageState createState() => _FirstListPageState();
}

class _FirstListPageState extends State<FirstListPage> {
  var isLoading = false;
  final String baseUrl = Utils.baseURL;
  List data = List();
  String _textItem;
  String _selectValue;

  File selectedFile;
  Project project = Project();
  DefectDBHelper defectDBHelper = DefectDBHelper();
  ProjectAPI getProject = ProjectAPI();

  @override
  void initState() {
    super.initState();
    readAllProject();
  }

  Future<String> readAllProject() async {
    Response response = await Dio().get('$baseUrl/projectapi');
    var resBody = response.data;
    if(mounted) setState(() {
      data = resBody;
    });

    print(resBody);

    return "Sucess";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Text('โปรเจค : '),
              //bulidDropDownMenu(),
              SizedBox(width: 10),
              syncDataForDownload(),
              SizedBox(width: 10),
              //deleteAllList()
            ],
          ),
          Expanded(child: buildListTileItem())
        ],
      ),
    );
  }

  Widget bulidDropDownMenu() {
    return DropdownButton(
      hint: Text('เลือกโปรเจค'),
      items: data.map((item) {
        _textItem = item['projectid'] + ' ' + item['projectname'];
        return DropdownMenuItem(
          child: Text(_textItem),
          value: _textItem,
        );
      }).toList(),
      onChanged: (String newVal) {
        setState(() {
          _selectValue = newVal;
          //print(_selectValue);
        });
      },
      value: _selectValue,
    );
  }

  Widget syncDataForDownload() {
    return IconButton(
        icon: Icon(Icons.cloud_download),
        onPressed: () async {
          await _loadFromApi();
        });
  }

  Widget deleteAllList() {
    return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await _deleteAllData();
        });
  }

  Widget buildListTileItem() {
    return FutureBuilder(
        future: defectDBHelper.readDefects(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List myDefects = [];
            List dfList = [];
            List filter = [];
            for (var i = 0; i < snapshot.data.length; i++) {
              if (snapshot.data[i].uploaded == 0) {
                myDefects.add('Name : ${snapshot.data[i].name}'
                    '\n'
                    'Project : ${snapshot.data[i].projectname}'
                    '\n'
                    'Detail : ${snapshot.data[i].detail}'
                    '\n'
                    'Location : ${snapshot.data[i].location}'
                    '\n'
                    'Checker : ${snapshot.data[i].checker}'
                    '\n'
                    //'Uploaded : ${snapshot.data[i].uploaded}'
                    );
              }else{
                myDefects.add('Name : ${snapshot.data[i].name}'
                    '\n'
                    'Project : ${snapshot.data[i].projectname}'
                    '\n'
                    'Detail : ${snapshot.data[i].detail}'
                    '\n'
                    'Location : ${snapshot.data[i].location}'
                    '\n'
                    'Checker : ${snapshot.data[i].checker}'
                    '\n'
                    //'Uploaded : ${snapshot.data[i].uploaded}'
                    );
              }
            }
            // dfList = myDefects;
            // filter.addAll(dfList);
            // if (_selectValue.toString() == null) {
            //   filter.addAll(dfList);
            // } else {
            //   filter = [];
            //   print("filter project for : $_selectValue");
            //   for (var i = 0; i < snapshot.data.length; i++) {
            //     if (snapshot.data[i].projectname == _selectValue.toString()) {
            //       filter.add('Name : ${snapshot.data[i].name}'
            //           '\n'
            //           'Project : ${snapshot.data[i].projectname}'
            //           '\n'
            //           'Detail : ${snapshot.data[i].detail}'
            //           '\n'
            //           'Location : ${snapshot.data[i].location}'
            //           '\n'
            //           'Checker : ${snapshot.data[i].checker}');
            //     }
            //   }
            //   myDefects = filter;
            // }
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.black12,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: 100, maxHeight: 100),
                      child: Image.asset('assets/noimage.jpg'),
                    ),
                    subtitle: Text(myDefects[index].toString()),
                    trailing: IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        onPressed: () async {
                          var image = await ImagePicker().getImage(
                              source: ImageSource.camera,
                              maxWidth: 630,
                              maxHeight: 840);
                          if (image != null) {
                            this.setState(() {
                              selectedFile = File(image.path);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PhotoDraw2(
                                        snapshot.data[index].id,
                                        selectedFile,
                                        snapshot.data[index].projectname,
                                        snapshot.data[index].name,
                                        snapshot.data[index].detail,
                                        snapshot.data[index].location,
                                        snapshot.data[index].checker,
                                        snapshot.data[index].uploaded)),
                              );
                              print(selectedFile);
                            });
                          }
                        }),
                    onTap: () {},
                  ),
                );
              },
              itemCount: myDefects.length
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  _loadFromApi() async {
    setState(() {
      isLoading = true;
    });

    var api = DefectAPI();
    await api.getAllDefects();

    // wait for 2 seconds to simulate loading of data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  _deleteAllData() async {
    if(mounted) setState(() {
      isLoading = true;
    });

    await defectDBHelper.deleteAllDefect();

    // wait for 1 second to simulate loading of data
    await Future.delayed(const Duration(seconds: 1));

    if(mounted) setState(() {
      isLoading = false;
    });

    print('All defects deleted');
  }
}
