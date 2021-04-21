import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/api/defect_restapi.dart';
import 'package:tace_nowait/database/defect_dbhelper.dart';
import 'package:tace_nowait/database/defectmedia_dbhelper.dart';
import 'package:tace_nowait/model/defect.dart';
import 'package:tace_nowait/model/defectmedia.dart';
import 'package:tace_nowait/pages/home.dart';

class ProfileForm2 extends StatefulWidget {
  final int selectedID;
  final File photoFile;
  final File drawFile;
  final String widgetProjectName;
  final String widgetName;
  final String widgetDetail;
  final String widgetLocation;
  final String widgetChecker;
  final widgetUploaded;

  ProfileForm2(
      this.selectedID,
      this.photoFile,
      this.drawFile,
      this.widgetProjectName,
      this.widgetName,
      this.widgetDetail,
      this.widgetLocation,
      this.widgetChecker,
      this.widgetUploaded);

  @override
  _ProfileForm2State createState() => _ProfileForm2State();
}

class _ProfileForm2State extends State<ProfileForm2> {
  GlobalKey<ScaffoldMessengerState> _scaffoldState =
      GlobalKey<ScaffoldMessengerState>();

  FlutterAudioRecorder _recorder;
  Recording _currentAudioFile;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  Defect defect;
  DefectAPI api;
  DefectDBHelper dfHelper;
  DefectMedia defectMedia;
  DefectMediaDBHelper dfmHelper;

  String audioRecStatus = 'ยังไม่มีการบันทึกเสียง';
  String audioRecFile;

  @override
  void initState() {
    super.initState();
    defect = Defect();
    api = DefectAPI();
    dfHelper = DefectDBHelper();
    defectMedia = DefectMedia();
    dfmHelper = DefectMediaDBHelper();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    audioRecFile = _currentAudioFile?.path?.split('/')?.last;

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Add Profile'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_currentAudioFile != null) {
                  saveToDatabase();
                  dfHelper.deleteDefect(widget.selectedID);
                  api.updateStatusDefect(widget.selectedID);
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
                Text('Name : ${widget.widgetName}'),
                SizedBox(height: 10),
                Text('Deatil : ${widget.widgetDetail}'),
                SizedBox(height: 10),
                Text('Location : ${widget.widgetLocation}'),
                SizedBox(height: 10),
                Text('Checker : ${widget.widgetChecker}'),
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
    defectMedia = DefectMedia(
        photo: widget.photoFile.path,
        drawphoto: widget.drawFile.path,
        projectname: widget.widgetProjectName,
        name: widget.widgetName,
        detail: widget.widgetDetail,
        location: widget.widgetLocation,
        checker: widget.widgetChecker,
        audio: _currentAudioFile.path);
    dfmHelper.createDefectMedia(defectMedia);
  }
}
