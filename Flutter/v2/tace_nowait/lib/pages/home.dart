import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tace_nowait/auth/auth.dart';
import 'package:tace_nowait/pages/addprojectcode.dart';
import 'package:tace_nowait/pages/firstlistpage.dart';
import 'package:tace_nowait/pages/otherlistpage.dart';
import 'package:tace_nowait/pages/photodraw.dart';
import 'package:tace_nowait/pages/secondlistpage.dart';
import 'package:tace_nowait/pages/settingpage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _pages;
  int currentIndexBottom = 0;
  File selectedFile;
  String userName = '';

  @override
  void initState() {
    super.initState();
    getNamePreference().then((user) => checkUsername(user));
    _pages = []..add(TabPage())..add(SettingPage());
  }

  void checkUsername(String name) {
    setState(() {
      userName = name;
    });
  }

  getNamePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('username');
    return name;
  }

  Future<bool> saveStatusPreference(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('status', name);
    return prefs.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TACE NOWAIT')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  Text('สวัสดีคุณ $userName', style: TextStyle(fontSize: 20)),
              accountEmail: null,
            ),
            ////Menu 1////
            // ListTile(
            //   leading: Icon(Icons.add_box_outlined),
            //   title: Text('My project'),
            //   onTap: () {
            //     print('Add project');
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => AddProjectCode())
            //     );
            //   },
            // ),
            ////Menu 2////
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Help'),
              onTap: () {
                print('Settings project');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
            ),
            ////Menu 3////
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                print('logout');
                setState(() {
                  String statuscode = 'failed';
                  saveStatusPreference(statuscode);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AuthScreen()));
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentIndexBottom,
        children: _pages,
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.white,
      //   child: Row(
      //     children: [
      //       Expanded(child: SizedBox()),
      //       IconButton(
      //         icon: Icon(
      //           Icons.sync,
      //           color: Colors.black,
      //         ),
      //         onPressed: () {},
      //       ),
      //     ],
      //   ),
      // ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1338BE),
        tooltip: 'Increment',
        child: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage(ImageSource.camera);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  getImage(ImageSource source) async {
    var image = await ImagePicker()
        .getImage(source: source, maxWidth: 630, maxHeight: 840);
    if (image != null) {
      this.setState(() {
        selectedFile = File(image.path);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PhotoDraw(selectedFile)),
        );
      });
    }
  }
}

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Tab> topTabs = <Tab>[
    Tab(text: 'Working'),
    Tab(text: 'Done'),
    Tab(text: 'Other'),
  ];

  final tabPages = [
    FirstListPage(),
    SecondListPage(),
    OtherListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: false,
            tabs: topTabs,
          ),
        ),
        body: TabBarView(children: tabPages),
      ),
      length: topTabs.length,
    );
  }
}

// class MainDrawer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           createTextHeader(),
//           ////Menu 1////
//           ListTile(
//             leading: Icon(Icons.exit_to_app),
//             title: Text('Logout'),
//             onTap: () {
//               print('logout');
//               // Navigator.pushReplacement(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => ())
//               // );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget createTextHeader() {
//     return UserAccountsDrawerHeader(
//       accountName: Text('สวัสดีคุณ $username', style: TextStyle(fontSize: 25)),
//       accountEmail: null,
//     );
//   }
// }
