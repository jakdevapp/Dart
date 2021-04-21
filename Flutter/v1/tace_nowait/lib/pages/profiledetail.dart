import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tace_nowait/database/profile_dbhelper.dart';
import 'package:tace_nowait/model/profile.dart';
import 'package:tace_nowait/pages/home.dart';
import 'package:tace_nowait/pages/profileedit.dart';

class ProfileDetail extends StatefulWidget {
  final Profile profile;
  ProfileDetail(this.profile);

  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  ProfileDBHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = ProfileDBHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Photo Detail'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showPhoto(),
            SizedBox(height: 5),
            showContent(),
            SizedBox(height: 5),
            showAudio(),
            SizedBox(height: 5),
            showPlayAudioButton(),
            SizedBox(height: 5),
            showDateTime(),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showEditButton(widget.profile.id),
                SizedBox(width: 20),
                showDeleteButton(widget.profile.id),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget showPhoto() {
    return Container(
      child: Image.file(File(widget.profile.drawphoto)),
      width: 400.0,
      height: 400.0,
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
    );
  }

  Widget showContent() {
    return Text(
      'ชื่อโครงการ : ${widget.profile.projectname}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showAudio() {
    return Text(
      'Audio : ${widget.profile.audio.split('/').last}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showPlayAudioButton() {
    return FlatButton.icon(
        color: Color(0xFF1338BE),
        icon: Icon(Icons.play_arrow, color: Colors.white),
        label:
            Text('Play', style: TextStyle(color: Colors.white, fontSize: 20)),
        onPressed: () {
          onPlayAudio();
        });
  }

  Widget showDateTime() {
    return Text(
      'Date & Time : ${widget.profile.datetimestamp}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showEditButton(int index) {
    return FlatButton.icon(
        color: Color(0xFF1338BE),
        icon: Icon(Icons.edit, color: Colors.white),
        label:
            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 20)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileEdit(widget.profile)),
          );
        });
  }

  Widget showDeleteButton(int index) {
    return FlatButton.icon(
        color: Color(0xFF1338BE),
        icon: Icon(Icons.delete, color: Colors.white),
        label:
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 20)),
        onPressed: () {
          return showDialog<Null>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Are you sure want to delete data on ${widget.profile.projectname}?',
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
                          _dbHelper.deleteProfile(widget.profile.id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                          _scaffoldState.currentState.showSnackBar(SnackBar(
                            content: Text('Delete data success !'),
                          ));
                        }),
                  ],
                );
              });
        });
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(File(widget.profile.audio).path, isLocal: true);
  }
}
