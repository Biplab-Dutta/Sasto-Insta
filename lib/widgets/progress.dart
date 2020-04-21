import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
    ),
  );
}

Container linearProgress() {
  return Container(
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
    ),
  );
}
