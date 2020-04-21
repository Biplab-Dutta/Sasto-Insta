import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false,
    String titleText,
    bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Sasto_Insta' : titleText,
      style: TextStyle(
        fontFamily: isAppTitle ? 'Pacifico' : "",
        fontSize: isAppTitle ? 42 : 22,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
