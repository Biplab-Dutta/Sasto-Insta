import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_network/widgets/header.dart';

final _formKey = GlobalKey<FormState>();
final _scaffoldKey = GlobalKey<ScaffoldState>();

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(
        content: Text('Welcome $username!'),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: 'Set up your profile', removeBackButton: true),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                'Create a username',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: TextFormField(
                  validator: (val) {
                    if (val.trim().length < 3 || val.isEmpty) {
                      return "Username too short!";
                    } else if (val.trim().length > 12) {
                      return "Username too long";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) => username = val,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        fontSize: 15.0,
                      ),
                      hintText: 'Must be at least 3 characters!'),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(7.0),
              ),
              height: 50,
              width: 350,
              child: Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
