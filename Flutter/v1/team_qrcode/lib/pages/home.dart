import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_qrcode/pages/addpage.dart';
import 'package:team_qrcode/pages/scanpage.dart';
import 'package:team_qrcode/auth/auth.dart';
import 'package:team_qrcode/database/sqlitedb.dart';
import 'package:team_qrcode/pages/viewpage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _pages;
  int currentIndexBottom = 0;
  SqlDatabase database = SqlDatabase();
  String userName = '';

  void initState() {
    super.initState();
    getNamePreference().then((user) => checkUsername(user));
    _pages = List()..add(TabPage());
  }

  getNamePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('username');
    return name;
  }

  void checkUsername(String name) {
    setState(() {
      userName = name;
    });
  }

  Future<bool> saveStatusPreference(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('status', name);
    return prefs.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TEAM QR CODE')),
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
    );
  }
}

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Tab> topTabs = <Tab>[Tab(text: 'Scan'), Tab(text: 'Add'), Tab(text: 'View')];

  final tabPages = [ScanPage(), AddPage(), ViewPage()];

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
