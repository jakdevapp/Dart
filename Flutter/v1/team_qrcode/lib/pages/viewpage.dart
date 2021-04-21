import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPage extends StatefulWidget {
  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            //_buildAddButton(),
            SizedBox(height: 20),
            Text('ดูข้อมูลได้ที่ http://uncle-machine.com:7000/'),
            _buildViewButton()
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton() {
    return RaisedButton(
        color: Color(0xFF1338BE),
        child: Text(
          "ดูข้อมูล",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _launchURL();
        });
  }

  _launchURL() async {
    const url = 'http://uncle-machine.com:7000/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}