import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/database/profile_dbhelper.dart';
import 'package:tace_nowait/model/profile.dart';
import 'package:tace_nowait/pages/home.dart';

import 'package:dio/dio.dart';
import 'package:tace_nowait/util/util.dart';

class ProfileForm extends StatefulWidget {
  final File photoFile;
  final File drawFile;
  ProfileForm(this.photoFile, this.drawFile);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  GlobalKey<ScaffoldMessengerState> _scaffoldState =
      GlobalKey<ScaffoldMessengerState>();
  TextEditingController _controllerContent;
  bool isFieldContentValid;
  String audioRecStatus = 'ยังไม่มีการบันทึกเสียง';
  String audioRecFile;
  String stampDateTime;
  String stampDateTimeFormat;

  FlutterAudioRecorder _recorder;
  Recording _currentAudioFile;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  Profile profile;
  ProfileDBHelper dbHelper;

  final String baseUrl = Utils.baseURL;
  String _mySelection;
  List data = [];

  Future<String> getPJData() async {
    Response response = await Dio().get('$baseUrl/projectapi');
    var resBody = response.data;
    setState(() {
      data = resBody;
    });

    print(resBody);

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    _controllerContent = TextEditingController();
    stampDateTime = DateTime.now().toIso8601String();
    profile = Profile();
    dbHelper = ProfileDBHelper();
    _init();
    getPJData();
  }

  @override
  Widget build(BuildContext context) {
    String date = stampDateTime.split('T').first;
    String time = stampDateTime.split('T').last;
    stampDateTimeFormat = date + ' ' + time.substring(0, 8);
    audioRecFile = _currentAudioFile?.path?.split('/')?.last;

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Add Profile'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_currentAudioFile != null && _controllerContent != null) {
                  saveToDatabase();
                  showDialog<Null>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'บันทึกข้อมูลเรียบร้อยแล้ว',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.1),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
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
                } else {
                  _scaffoldState.currentState.showSnackBar(
                      SnackBar(content: Text('Please fill data all field !')));
                }
              })
        ],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Drawing photo'),
                SizedBox(height: 10),
                _buildImageWidget(),
                SizedBox(height: 10),
                Text('File : ${widget.drawFile.path.split('/').last}'),
                SizedBox(height: 10),
                Text('รหัสโปรเจค : P101'),
                SizedBox(height: 10),
                Text('ชื่อโปรเจค : คอนโด'),
                SizedBox(height: 10),
                //_buildContent(),
                //Text(_controllerContent.text),
                SizedBox(height: 30),
                Text('$audioRecStatus'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildRecordButton(),
                    _buildStopButton(),
                    _buildPlayButton(),
                  ],
                ),
                SizedBox(height: 10),
                Text('File : $audioRecFile'),
              ],
            ),
            SizedBox(height: 20),
            Text('Stamp Date & Time : $stampDateTimeFormat',
                style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Image.file(
      widget.drawFile,
      width: 250,
      height: 250,
      fit: BoxFit.cover,
    );
  }

  Widget _buildRecordButton() {
    return ElevatedButton.icon(
        //color: Color(0xFF1338BE),
        icon: Icon(Icons.fiber_manual_record, color: Colors.white),
        label: Text(''),
        onPressed: () {
          _start();
        });
  }

  Widget _buildStopButton() {
    return ElevatedButton.icon(
        //color: Color(0xFF1338BE),
        icon: Icon(Icons.stop, color: Colors.white),
        label: Text(''),
        onPressed: () {
          _stop();
        });
  }

  Widget _buildPlayButton() {
    return ElevatedButton.icon(
        //color: Color(0xFF1338BE),
        icon: Icon(Icons.play_arrow, color: Colors.white),
        label: Text(''),
        onPressed: () {
          onPlayAudio();
        });
  }

  Widget _buildContent() {
    return TextField(
      controller: _controllerContent,
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
      onSubmitted: (value) {
        print(value);
      },
    );
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        DateTime dateTime = DateTime.now();
        final DateFormat df = DateFormat("ddMMyyyy_HHmmss");
        String dtFileFormat = df.format(dateTime);

        Directory appDocDirectory;
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        String customPath;
        customPath = appDocDirectory.path + '/audio_' + dtFileFormat;
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        var current = await _recorder.current(channel: 0);
        print(current);
        setState(() {
          _currentAudioFile = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _currentAudioFile = recording;
      });

      const tick = const Duration(milliseconds: 50);
      Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        setState(() {
          _currentAudioFile = current;
          _currentStatus = _currentAudioFile.status;
          audioRecStatus = 'กำลังบันทึกเสียง...';
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    setState(() {
      audioRecStatus = 'บันทึกเสียงเรียบร้อยแล้ว';
      audioRecFile = _currentAudioFile?.path?.split('/')?.last;
      _currentAudioFile = result;
      _currentStatus = _currentAudioFile.status;
    });
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_currentAudioFile.path, isLocal: true);
  }

  saveToDatabase() {
    String photoPath = widget.photoFile.path;
    String drawPhotoPath = widget.drawFile.path;
    String audioPath = _currentAudioFile.path;
    String contentText = '_controllerContent.text';
    String dtStamp = stampDateTimeFormat;

    profile = Profile(
        photo: photoPath,
        drawphoto: drawPhotoPath,
        projectid: 'P101',
        projectname: 'คอนโด',
        content: 'contentText',
        audio: audioPath,
        datetimestamp: dtStamp,
        uploaded: false);
    dbHelper.createProfile(profile);
  }
}
