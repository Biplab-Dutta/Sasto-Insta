import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SastoInsta',
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Home(),
      ),
      theme: ThemeData(
        primaryColor: Colors.red[400],
        primaryColorLight: Colors.grey[700],
        primaryColorDark: Colors.black,
      ),
    );
  }
}
