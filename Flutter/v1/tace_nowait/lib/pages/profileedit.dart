import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tace_nowait/database/profile_dbhelper.dart';
import 'package:tace_nowait/model/profile.dart';
import 'package:tace_nowait/pages/home.dart';

class ProfileEdit extends StatefulWidget {
  final Profile profile;
  ProfileEdit(this.profile);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  Profile profile;
  ProfileDBHelper dbHelper;

  TextEditingController editContent = TextEditingController();
  bool isFieldContentValid;
  String dtStamp;
  String stampDateTimeFormat;

  @override
  void initState() {
    dbHelper = ProfileDBHelper();
    editContent.text = widget.profile.projectname;
    dtStamp = DateTime.now().toIso8601String();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String date = dtStamp.split('T').first;
    String time = dtStamp.split('T').last;
    stampDateTimeFormat = date + ' ' + time.substring(0,8);
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Edit Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              editProfileDatabase();
              return showDialog<Null>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Data was been updated into database.',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 1.1),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          },
                        ),
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _showImageWidget(),
                SizedBox(height: 10),
                _buildContent(),
                SizedBox(height: 10),
                showAudio(),
                SizedBox(height: 10),
                showPlayAudioButton(),
              ],
            ),
            SizedBox(height: 10),
            Text('Stamp Date & Time : $stampDateTimeFormat',
                style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _showImageWidget() {
    return Image.file(
      File(widget.profile.drawphoto),
      width: 250,
      height: 250,
      fit: BoxFit.cover,
    );
  }

  Widget _buildContent() {
    return TextField(
      controller: editContent,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Content",
        errorText: isFieldContentValid == null || isFieldContentValid
            ? null
            : "Content is required",
      ),
      onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != isFieldContentValid) {
          setState(() => isFieldContentValid = isFieldValid);
        }
      },
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

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(File(widget.profile.audio).path, isLocal: true);
  }

  editProfileDatabase() {
    String photoPath = widget.profile.photo;
    String drawPhotoPath = widget.profile.drawphoto;
    String audioPath = widget.profile.audio;
    String photoContent = editContent.text;

    profile = Profile(
        id: widget.profile.id,
        photo: photoPath,
        drawphoto: drawPhotoPath,
        audio: audioPath,
        projectname: photoContent,
        datetimestamp: dtStamp);
    dbHelper.updateProfile(profile);
  }
}
