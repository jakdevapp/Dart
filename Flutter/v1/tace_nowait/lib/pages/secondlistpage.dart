import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tace_nowait/api/defectmedia_restapi.dart';
import 'package:tace_nowait/database/defectmedia_dbhelper.dart';
import 'package:tace_nowait/model/defectmedia.dart';
import 'package:tace_nowait/pages/profiledetail2.dart';
import 'package:tace_nowait/util/util.dart';

class SecondListPage extends StatefulWidget {
  @override
  _SecondListPageState createState() => _SecondListPageState();
}

class _SecondListPageState extends State<SecondListPage> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  var _defectMedias;
  List<DefectMedia> _dfmList;
  List<DefectMedia> _filter;
  List<bool> _dfmBool;
  
  final String baseUrl = Utils.baseURL;
  List data = List();
  String _selectValue;

  DefectMediaDBHelper _dfmHelper;
  DefectMedia _alldfm;
  DefectMediaAPI _api;

  @override
  initState() {
    super.initState();
    //filterProject();
    getAllList();
    readAllProject();
  }

  getAllList() async {
    _dfmList = List<DefectMedia>();
    _dfmHelper = DefectMediaDBHelper();
    _defectMedias = await _dfmHelper.readDefectMedias();
    _dfmBool = List.generate(_defectMedias.length, (index) => false);

    _defectMedias.forEach((item) {
      setState(() {
        var model = DefectMedia(
            id: item.id,
            photo: item.photo,
            drawphoto: item.drawphoto,
            projectname: item.projectname,
            name: item.name,
            detail: item.detail,
            location: item.location,
            checker: item.checker,
            audio: item.audio
        );
        model.id = item.id;
        model.photo = item.photo;
        model.drawphoto = item.drawphoto;
        model.projectname = item.projectname;
        model.name = item.name;
        model.detail = item.detail;
        model.location = item.location;
        model.checker = item.checker;
        model.audio = item.audio;
        _dfmList.add(model);
      });
      _alldfm = DefectMedia();
      _api = DefectMediaAPI();
    });
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

  Future filterProject() async {
    _dfmList.clear();
    _dfmList = _filter;

    if (_selectValue.toString() == 'All') {
      _filter.addAll(_defectMedias);
    } else {
      _filter = [];
      print("filter project for : $_selectValue");
      for (DefectMedia p in _defectMedias) {
        if (p.projectname == _selectValue.toString()) {
          _filter.add(p);
        }
      }
      _dfmList = _filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    //filterProject();
    return Scaffold(
        key: _scaffoldState,
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Text('โปรเจค : '),
                //bulidDropDownMenu(),
                SizedBox(width: 35),
                syncDataForUpload(),
                SizedBox(width: 20),
              ],
            ),
            Expanded(child: buildListTileItem())
          ],
        ));
  }

  Widget bulidDropDownMenu() {
    return DropdownButton(
      hint: Text('เลือกโปรเจค'),
      items: data.map((item) {
        return DropdownMenuItem(
          child: Text(item['projectid'] + ' ' + item['projectname']),
          value: item['id'].toString(),
        );
      }).toList(),
      onChanged: (newVal) {
        setState(() {
          _selectValue = newVal;
          print(_selectValue);
        });
      },
      value: _selectValue,
    );
  }

  Widget syncDataForUpload() {
    return IconButton(icon: Icon(Icons.cloud_upload), onPressed: () async {});
  }

  Widget buildListTileItem() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: _dfmBool[index] ? Colors.green[100] : Colors.white,
          child: ListTile(
            //selected: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            leading: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
              child: Image.file(File(_dfmList[index].drawphoto)),
            ),
            title: Text('Name : ${_dfmList[index].name}'),
            subtitle: Text('Project : ${_dfmList[index].projectname}'
                '\n'
                'Detail : ${_dfmList[index].detail}'
                '\n'
                'Location : ${_dfmList[index].location}'
                '\n'
                'Checker : ${_dfmList[index].checker}'),
            trailing: IconButton(
                icon: Icon(Icons.description, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileDetail2(_dfmList[index])),
                  );
                }),
            isThreeLine: true,
            onLongPress: () {
              setState(() {
                _dfmBool[index] = true;
                print('ID : ${_dfmList[index].id} ${_dfmBool[index]}');
              });
            },
            onTap: () {
              // if (_dfmBool.any((item) => item)) {
              //   setState(() {
              //     _dfmBool[index] = !_dfmBool[index];
              //     print('ID : ${_dfmList[index].id} ${_dfmBool[index]}');
              //   });
              // }
              return showDialog<Null>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'คุณต้องการอัพโหลดข้อมูลหรือไม่ ?',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 1.1),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("No"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                            child: Text("Yes",
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              _alldfm = DefectMedia(
                                photo: _dfmList[index].photo,
                                drawphoto: _dfmList[index].drawphoto,
                                audio: _dfmList[index].audio,
                                projectname: _dfmList[index].projectname,
                                name: _dfmList[index].name,
                                detail: _dfmList[index].detail,
                                location: _dfmList[index].location,
                                checker: _dfmList[index].checker,
                              );
                              print(_dfmList[index].photo);
                              print(_dfmList[index].drawphoto);
                              print(_dfmList[index].audio);
                              print(_dfmList[index].projectname);
                              print(_dfmList[index].name);
                              print(_dfmList[index].detail);
                              print(_dfmList[index].location);
                              print(_dfmList[index].checker);
                              _api
                                  .createDefectMedia(_alldfm)
                                  .then((result) async {
                                    _dfmHelper.deleteDefectMedia(_dfmList[index].id);
                                    setState(() {
                                      getAllList();
                                    });
                                    print(result);
                              });
                              Navigator.pop(context);
                            }),
                      ],
                    );
                  });
            },
            dense: false,
            enabled: true,
          ),
        );
      },
      itemCount: _dfmList.length,
    );
  }
}
