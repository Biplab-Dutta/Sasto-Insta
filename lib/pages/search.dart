import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final firestore = FirebaseFirestore.instance;
  Future<QuerySnapshot> searchedUser;
  void handleSearch(String name) {
    Future<QuerySnapshot> users = firestore
        .collection('users')
        .where(
          'displayName',
          isGreaterThanOrEqualTo: name[0].toUpperCase() + name.substring(1),
        ) //converting 1st character of the name to uppercase.
        .get();
    setState(
      () {
        searchedUser = users;
      },
    );
  }

  final TextEditingController textController = TextEditingController();
  AppBar buildSearchField() {
    return AppBar(
      title: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Search for users...',
          filled: true,
          prefixIcon: Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              SchedulerBinding.instance.addPostFrameCallback(
                (_) {
                  textController.clear();
                },
              );
            },
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildNoContent() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/search.svg',
                height: orientation == Orientation.portrait ? 300 : 175,
              ),
              Text(
                'Find Users',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: orientation == Orientation.portrait ? 70 : 60,
                    color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
      future: searchedUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResultInList = [];
        snapshot.data.docs.forEach(
          (doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResultInList.add(searchResult);
          },
        );
        return ListView(
          children: searchResultInList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchedUser == null ? buildNoContent() : buildSearchResult(),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
