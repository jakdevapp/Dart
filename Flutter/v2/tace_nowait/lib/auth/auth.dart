import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tace_nowait/pages/home.dart';
import 'package:tace_nowait/util/util.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var currentstatus = '';
  void initState() {
    getStatusPreference().then(checkUserName);
    super.initState();
  }

  TextEditingController ctrlUsermane = TextEditingController();
  TextEditingController ctrlPassword = TextEditingController();
  var checkresult = '';

  void checkUserName(String name) {
    setState(() {
      this.currentstatus = name;
      if (this.currentstatus == 'success') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  void doLogin() {
    print(ctrlUsermane.text);
    print(ctrlPassword.text);

    _makePostRequest2();
  }

  Future<void> _makePostRequest2() async {
    var v1 = ctrlUsermane.text;
    var v2 = ctrlPassword.text;

    // set up POST request arguments
    String url = '${Utils.baseURL}/apicheckuser/';
    Map<String, String> headers = {"Content-type": "application/json"};

    String jsondata = '{"username": "$v1", "password": "$v2"}';
    // make POST request
    var response =
        await http.post(Uri.parse(url), headers: headers, body: jsondata);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;
    print('---CODE---');
    print(statusCode);
    print('---BODY---');
    print(body);

    setState(() {
      var valueMap = json.decode(body);
      if (valueMap['result'] == 'success') {
        this.checkresult = 'success';
      } else {
        this.checkresult = 'failed';
      }
    });
    print('-----RESULT FINAL-----');
    print(checkresult);

    if (checkresult == 'success') {
      String name = ctrlUsermane.text;
      String statuscode = 'success';
      saveStatusPreference(statuscode);
      saveNamePreference(name).then((bool committed) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    } else {
      _showDialog();
    }

    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Please check error"),
          content: Text(
            'username หรือ password ผิด กรุณาตรวจสอบอีกครั้ง',
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'THKrub',
                color: Colors.black),
            maxLines: 1,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> saveNamePreference(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', name);
    return prefs.commit();
  }

  Future<String> getNamePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('username');
    return name;
  }

  Future<bool> saveStatusPreference(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('status', name);
    return prefs.commit();
  }

  Future<String> getStatusPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('status');
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: Colors.white),
          Center(
              child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Image(
                        height: 280.0,
                        width: 280.0,
                        image: AssetImage('assets/noimage.jpg')),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'ลงชื่อเพื่อเข้าสู่แอพพลิเคชั่น',
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'THKrub'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: ctrlUsermane,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            // fontFamily: 'THKrub'),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: 'ชื่อผู้ใช้งาน [Username]',
                              focusColor: Colors.black,
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: ctrlPassword,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            // fontFamily: 'THKrub'),
                            keyboardType: TextInputType.emailAddress,

                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key),
                              labelText: 'รหัสผ่าน [Password]',
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MaterialButton(
                                onPressed: () => doLogin(),
                                child: Text(
                                  'เข้าสู่ระบบ',
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'THKrub',
                                      color: Colors.white),
                                  maxLines: 1,
                                ),
                                color: Colors.blue[900],
                                elevation: 5.0,
                                splashColor: Colors.orange[300],
                                highlightColor: Colors.orange[400],
                                minWidth: 100.0,
                                height: 45.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }
}
