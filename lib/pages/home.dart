import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/activity_feed.dart';
import 'package:social_network/pages/create_account.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/pages/search.dart';
//import 'package:social_network/pages/timeline.dart';
import 'package:social_network/pages/upload.dart';

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final firestore = Firestore.instance;
  int pageIndex = 0;
  PageController pageController = PageController();
  final DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return isAuth ? authScreen() : unAuthScreen();
  }

  @override
  void initState() {
    super.initState();
    googleSignIn.signInSilently(suppressErrors: false).then(
      (GoogleSignInAccount loggedInUser) {
        handleSignIn(loggedInUser);
      },
    ).catchError(
      (onError) {
        print(onError);
      },
    );
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(
      () {
        this.pageIndex = pageIndex;
        FocusScope.of(context).unfocus();
      },
    );
  }

  onTap(int pageIndex) {
    setState(
      () {
        pageController.animateToPage(
          pageIndex,
          duration: Duration(
            milliseconds: 250,
          ),
          curve: Curves.bounceInOut,
        );
      },
    );
  }

  void logOut() async {
    try {
      await googleSignIn.signOut();
      setState(
        () {
          isAuth = false;
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void logIn() async {
    try {
      final loggedInUser = await googleSignIn.signIn();
      handleSignIn(loggedInUser);
    } catch (e) {
      print(e);
    }
  }

  handleSignIn(GoogleSignInAccount gmailAccount) {
    if (gmailAccount != null) {
      createUserInFirebase(gmailAccount);
      setState(
        () {
          isAuth = true;
        },
      );
    }
  }

  createUserInFirebase(GoogleSignInAccount user) async {
    DocumentSnapshot userId =
        await firestore.collection('users').document(user.id).get();
    String username;
    if (!userId.exists) {
      username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      firestore.collection('users').document(user.id).setData(
        {
          "id": user.id,
          "username": username,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": dateTime,
        },
      );
      userId = await firestore.collection('users').document(user.id).get();
    }

    currentUser = User.fromDocument(userId);
  }

  Scaffold authScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          FlatButton(
            onPressed: logOut,
            child: Text('Logout'),
          ),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile()
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Timeline'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            title: Text('Actiivity Feed'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
            title: Text('Upload'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
        onTap: onTap,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  unAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sasto Insta',
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 60,
                color: Colors.black87,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: GestureDetector(
                onTap: () {
                  logIn();
                },
                child: Container(
                  height: 60,
                  width: 260,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
