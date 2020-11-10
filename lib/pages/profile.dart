import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/edit_profile.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/post.dart';
import 'package:social_network/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final User currentUser;
  Profile({this.profileId, this.currentUser});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(
      () {
        isLoading = true;
      },
    );
    QuerySnapshot snapshot = await firestore
        .collection("posts")
        .doc(widget.profileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .get();
    setState(
      () {
        isLoading = false;
        postCount = snapshot.docs.length;
        posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
      },
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUser: currentUser),
      ),
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      width: 250,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.blueAccent,
        onPressed: function,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isOwnerId = widget.currentUser.id == widget.profileId;
    if (isOwnerId) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    }
  }

  Widget buildProfileHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    radius: 40.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("Posts", postCount),
                            buildCountColumn("Followers", 0),
                            buildCountColumn("Following", 0),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildProfileButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    //fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  user.bio,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    //fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else {
      return Column(
        children: posts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F0E8),
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(height: 0.0),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
