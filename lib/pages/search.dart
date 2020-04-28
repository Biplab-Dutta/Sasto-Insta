import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int value;
  final TextEditingController textController = TextEditingController();
  AppBar buildSearchField() {
    return AppBar(
      title: TextFormField(
        onChanged: (val) {
          value = val.length;
        },
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
            )),
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
                'Search Users',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: buildNoContent(),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
