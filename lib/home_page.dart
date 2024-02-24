import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_buddy/widgets/collages_widget.dart';
import 'package:spotify_buddy/widgets/friendbar_widget.dart';
import 'package:spotify_buddy/widgets/recentlyplayed_widget.dart';
import 'package:spotify_buddy/widgets/recentlyplayedloading_widget.dart';
import 'package:spotify_buddy/main.dart';

class Home extends StatefulWidget {
  final args;
  final prefs;
  Home(this.args, this.prefs);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    PageController pagecontroller = PageController(initialPage: widget.args[1]);
    final access_token = widget.args[0];
    return SafeArea(
      child: FutureBuilder(
          future: apiSpotify(access_token),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var data = snapshot.hasData ? snapshot.data : null;
            if (snapshot.hasData &&
                data["recently-played"].containsKey("items")) {
              return PageView(
                controller: pagecontroller,
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 200, child: FriendBar(data)),
                  Container(
                      margin: EdgeInsets.only(left: 26.0, right: 26.0),
                      child: RecentlyPlayedView(data)),
                  CollagesView(data),
                ],
              );
            } else {
              return RecentlyPlayedLoading();
            }
          }),
    );
  }
}

class Welcome extends StatelessWidget {
  final args;
  Welcome(this.args);

  @override
  Widget build(BuildContext context) {
    var title = DateTime.now().hour < 11
        ? "Good morning."
        : DateTime.now().hour > 16
            ? "Good evening."
            : "Good afternoon.";
    return Container(
      padding: EdgeInsets.all(25),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Container(
          child: Text(title, style: googleText("title")),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                "/home",
                arguments: [args, 1],
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.indigo[300],
                ),
                width: double.infinity,
                height: 100,
                child: Center(
                    child: Text(
                  "View Recent Tracks",
                  style: googleText("subtitle"),
                )),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                "/home",
                arguments: [args, 2],
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.indigo[400],
                ),
                width: double.infinity,
                height: 100,
                child: Center(
                    child: Text(
                  "View Album Art",
                  style: googleText("subtitle"),
                )),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                "/home",
                arguments: [args, 0],
              ),
              child: Container(
                margin: EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.indigo[500],
                ),
                width: double.infinity,
                height: 100,
                child: Center(
                    child: Text(
                  "View Friends",
                  style: googleText("subtitle"),
                )),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
