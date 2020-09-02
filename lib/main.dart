import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SastoInsta',
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        primaryColor: Colors.red[400],
        primaryColorLight: Colors.grey[700],
        primaryColorDark: Colors.black,
      ),
    );
  }
}
