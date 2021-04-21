import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tace_nowait/api/profile_restapi.dart';
import 'package:tace_nowait/database/profile_dbhelper.dart';
import 'package:tace_nowait/model/profile.dart';
import 'package:tace_nowait/pages/profiledetail.dart';
import 'package:tace_nowait/util/util.dart';

class OtherListPage extends StatefulWidget {
  @override
  _OtherListPageState createState() => _OtherListPageState();
}

class _OtherListPageState extends State<OtherListPage> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  var _profiles;
  List<Profile> _profileList;
  List<bool> _profileBool;
  final String baseUrl = Utils.baseURL;
  List data = List();
  String _selectValue;
  bool _statusText;
  ProfileDBHelper _dbHelper;
  ProfileAPI _api;
  Profile _allprofile;

  @override
  initState() {
    super.initState();
    getAllList();
    readAllProject();
  }

  getAllList() async {
    _profileList = List<Profile>();
    _dbHelper = ProfileDBHelper();
    _profiles = await _dbHelper.readProfiles();
    _profileBool = List.generate(_profiles.length, (index) => false);

    _profiles.forEach((item) {
      if(mounted) setState(() {
        var model = Profile(
            id: item.id,
            photo: item.photo,
            drawphoto: item.drawphoto,
            projectid: item.projectid,
            projectname: item.projectname,
            audio: item.audio,
            datetimestamp: item.datetimestamp,
            uploaded: item.uploaded
        );
        model.id = item.id;
        model.photo = item.photo;
        model.drawphoto = item.drawphoto;
        model.projectid = item.projectid;
        model.projectname = item.projectname;
        model.audio = item.audio;
        model.datetimestamp = item.datetimestamp;
        model.uploaded = item.uploaded;
        _profileList.add(model);
      });
      _allprofile = Profile();
      _api = ProfileAPI();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Text('โปรเจค : '),
              //bulidDropDownMenu(),
              //SizedBox(width: 35),
              //syncDataForUpload(),
              //SizedBox(width: 20),
              //myPopupMenu()
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

  Widget buildListTileItem() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        _statusText = _profileList[index].uploaded;
        return Card(
          color: _profileBool[index] ? Colors.green[100] : Colors.white,
          child: ListTile(
            //selected: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            leading: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
              child: Image.file(File(_profileList[index].drawphoto)),
            ),
            title: Text('${_profileList[index].projectid} ${_profileList[index].projectname}'),
            subtitle: Text('$_statusText'),
            trailing: IconButton(
                icon: Icon(Icons.description, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileDetail(_profileList[index])),
                  );
                }),
            isThreeLine: true,
            onLongPress: () {
              setState(() {
                _profileBool[index] = true;
                print('ID : ${_profileList[index].id} ${_profileBool[index]}');
              });
            },
            onTap: () {
              // if (_profileBool.any((item) => item)) {
              //   setState(() {
              //     _profileBool[index] = !_profileBool[index];
              //     print('ID : ${_profileList[index].id} ${_profileBool[index]}');
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
                              setState(() {
                                _statusText = true;
                              });
                              _allprofile = Profile(
                                  photo: _profileList[index].photo,
                                  drawphoto: _profileList[index].drawphoto,
                                  projectid: _profileList[index].projectid,
                                  projectname: _profileList[index].projectname,
                                  content: _profileList[index].content,
                                  audio: _profileList[index].audio,
                                  datetimestamp: _profileList[index].datetimestamp,
                                  uploaded: _statusText
                              );
                              print(_profileList[index].photo);
                              print(_profileList[index].drawphoto);
                              print(_profileList[index].projectid);
                              print(_profileList[index].projectname);
                              print(_profileList[index].content);
                              print(_profileList[index].audio);
                              print(_profileList[index].datetimestamp);
                              print(_statusText);
                              _api
                                  .createProfile(_allprofile)
                                  .then((result) async {
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
      itemCount: _profileList.length,
    );
  }

  Widget syncDataForUpload() {
    return IconButton(
        icon: Icon(Icons.sync),
        onPressed: () {
          showDialog<Null>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Are you sure want to upload data on select item(s) ?',
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
                        child: Text("Yes", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          for (var i = 0; i < _profileList.length; i++) {
                            _allprofile = Profile(
                                photo: _profileList[i].photo,
                                drawphoto: _profileList[i].drawphoto,
                                audio: _profileList[i].audio,
                                projectname: _profileList[i].projectname,
                                datetimestamp: _profileList[i].datetimestamp);
                          }
                          print(_allprofile);
                          // api.createProfile(photo).then((value) {
                          //   print(value);
                          // });
                          print('The data was been synchronized !');
                          Navigator.pop(context);
                        }),
                  ],
                );
              });
        });
  }

  Widget myPopupMenu() {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            value: 1,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.done_all, color: Colors.black),
                ),
                Text('Select All')
              ],
            )),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.clear_all, color: Colors.black),
                ),
                Text('Unselect All')
              ],
            )),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            for (int i = 0; i < _profileList.length; i++) {
              setState(() {
                _profileBool[i] = true;
                print('ID : ${_profileList[i].id} ${_profileBool[i]}');
              });
            }
            break;
          case 2:
            for (int i = 0; i < _profileList.length; i++) {
              setState(() {
                _profileBool[i] = false;
                print('ID : ${_profileList[i].id} ${_profileBool[i]}');
              });
            }
            break;
        }
      },
    );
  }
}
