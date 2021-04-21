import 'package:flutter/material.dart';
import 'package:tace_nowait/api/project_restapi.dart';
import 'package:tace_nowait/model/project.dart';
import 'package:tace_nowait/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ProjectAPI getProject = ProjectAPI();
  Future<List<Project>> all;

  @override
  void initState() {
    super.initState();
    all = getProject.getAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TACE NOWAIT'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            //_buildAddButton(),
            SizedBox(height: 20),
            Text('หากมีปัญหา ให้ติตต่อ http://www.tace-cms.com/help'),
            _buildEditButton()
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return RaisedButton(
        color: Color(0xFF1338BE),
        child: Text(
          "Sync project",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          print(all);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });
  }

  Widget _buildEditButton() {
    return RaisedButton(
        color: Color(0xFF1338BE),
        child: Text(
          "ขอความช่วยเหลือ",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _launchURL();
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => EditProject()));
        });
  }

  _launchURL() async {
    const url = 'http://www.tace-cms.com/help';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
