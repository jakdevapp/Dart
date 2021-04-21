import 'package:flutter/material.dart';
import 'package:tace_nowait/auth/auth.dart';

void main() => runApp(MyApp());

const primaryColor = const Color(0xFF1338BE);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TACE NOWAIT',
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: AuthScreen(),
      //home: HomePage(),
    );
  }
}