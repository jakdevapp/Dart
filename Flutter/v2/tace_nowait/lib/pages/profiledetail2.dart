import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tace_nowait/database/defectmedia_dbhelper.dart';
import 'package:tace_nowait/model/defectmedia.dart';
import 'package:tace_nowait/pages/home.dart';

class ProfileDetail2 extends StatefulWidget {
  final DefectMedia defectMedia;
  ProfileDetail2(this.defectMedia);

  @override
  _ProfileDetail2State createState() => _ProfileDetail2State();
}

class _ProfileDetail2State extends State<ProfileDetail2> {
  GlobalKey<ScaffoldMessengerState> _scaffoldState =
      GlobalKey<ScaffoldMessengerState>();
  DefectMediaDBHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DefectMediaDBHelper();
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
            showProjectName(),
            SizedBox(height: 5),
            showName(),
            SizedBox(height: 5),
            showDetail(),
            SizedBox(height: 5),
            showLocation(),
            SizedBox(height: 5),
            showChecker(),
            SizedBox(height: 5),
            showAudio(),
            SizedBox(height: 5),
            showPlayAudioButton(),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showDeleteButton(widget.defectMedia.id),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget showPhoto() {
    return Container(
      child: Image.file(File(widget.defectMedia.drawphoto)),
      width: 400.0,
      height: 400.0,
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
    );
  }

  Widget showProjectName() {
    return Text(
      'Project : ${widget.defectMedia.projectname}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showName() {
    return Text(
      'Name : ${widget.defectMedia.name}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showDetail() {
    return Text(
      'Detail : ${widget.defectMedia.detail}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showLocation() {
    return Text(
      'Location : ${widget.defectMedia.location}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showChecker() {
    return Text(
      'Checker : ${widget.defectMedia.checker}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showAudio() {
    return Text(
      'Audio : ${widget.defectMedia.audio.split('/').last}',
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
    );
  }

  Widget showPlayAudioButton() {
    return ElevatedButton.icon(
        //color: Color(0xFF1338BE),
        icon: Icon(Icons.play_arrow, color: Colors.white),
        label:
            Text('Play', style: TextStyle(color: Colors.white, fontSize: 20)),
        onPressed: () {
          onPlayAudio();
        });
  }

  Widget showDeleteButton(int index) {
    return ElevatedButton.icon(
        //color: Color(0xFF1338BE),
        icon: Icon(Icons.delete, color: Colors.white),
        label:
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 20)),
        onPressed: () {
          return showDialog<Null>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Are you sure want to delete data on ${widget.defectMedia.name}?',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 1.1),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                        child: Text("Yes", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _dbHelper.deleteDefectMedia(widget.defectMedia.id);
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
    await audioPlayer.play(File(widget.defectMedia.audio).path, isLocal: true);
  }
}
