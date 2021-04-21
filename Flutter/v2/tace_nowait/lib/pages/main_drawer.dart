import 'package:flutter/material.dart';
import 'package:tace_nowait/auth/auth.dart';
import 'package:tace_nowait/pages/addproject.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createTextHeader(),
          ////Menu 1////
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Add project'),
            onTap: () {
              print('Add project');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddProject())
              );
            },
          ),
          ////Menu 2////
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              print('logout');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen())
              );
            },
          ),
        ],
      ),
    );
  }

  Widget createTextHeader(){
    return UserAccountsDrawerHeader(
      accountName: Text('สวัสดีคุณ สมชาย', style: TextStyle(fontSize: 25)), accountEmail: null,
    );
  }
}
