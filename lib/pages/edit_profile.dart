import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/home.dart';

class EditProfile extends StatefulWidget {
  final User currentUser;
  EditProfile({this.currentUser});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final _key = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool _displayNameValidity = true;
  bool _bioValidity = true;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  // @override
  // void initState() {
  //   super.initState();
  //   getUser();
  // }

  // getUser() async {
  //   setState(
  //     () {
  //       isLoading = true;
  //     },
  //   );
  //   setState(() {
  //     displayNameController.text = widget.currentUser.displayName;
  //     bioController.text = widget.currentUser.bio;
  //   });

  //   setState(
  //     () {
  //       isLoading = false;
  //     },
  //   );
  // }
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    DocumentSnapshot doc =
        await firestore.collection("users").doc(widget.currentUser.id).get();
    User user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
  }

  updateProfile() {
    FocusScope.of(context).unfocus();
    setState(
      () {
        displayNameController.text.trim().length < 3 ||
                displayNameController.text.trim().isEmpty
            ? _displayNameValidity = false
            : _displayNameValidity = true;
        bioController.text.trim().length > 100
            ? _bioValidity = false
            : _bioValidity = true;
      },
    );
    if (_displayNameValidity && _bioValidity) {
      firestore.collection("users").doc(widget.currentUser.id).update(
        {
          "displayName": displayNameController.text,
          "bio": bioController.text,
        },
      );
      SnackBar snackBar = SnackBar(
        content: Text("Profile successfully updated!"),
      );
      _key.currentState.showSnackBar(snackBar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.lightGreen,
              ),
              onPressed: () {
                updateProfile();
                Navigator.pop(context);
              },
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          widget.currentUser.photoUrl),
                      radius: 60,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: displayNameController,
                    // onChanged: (val) {
                    //   widget.currentUser.displayName = val;
                    // },
                    decoration: InputDecoration(
                      // hintText: "Update display name",
                      labelText: "Display name",
                      errorText: _displayNameValidity
                          ? null
                          : "Display Name too short!",
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: bioController,
                    decoration: InputDecoration(
                        // hintText: "Update display name",
                        labelText: "Bio",
                        errorText: _bioValidity ? null : "Bio too long!"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                    onPressed: updateProfile,
                    child: Text(
                      "Update Profile",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: logout,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
