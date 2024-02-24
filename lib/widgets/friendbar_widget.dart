import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_buddy/main.dart';
import 'package:http/http.dart' as requests;
import 'package:spotify_buddy/widgets/recentlyplayed_widget.dart';
import 'package:spotify_buddy/widgets/recentlyplayedloading_widget.dart';

StreamController friend_controller = StreamController.broadcast();

class FriendBar extends StatefulWidget {
  final user;
  FriendBar(this.user);

  @override
  _FriendBarState createState() => _FriendBarState();
}

class _FriendBarState extends State<FriendBar> {
  var friend_not_found = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 26.0, right: 26.0),
      child: StreamBuilder(
          stream: friend_controller.stream,
          builder: (context, snapshot) {
            return Stack(
              children: [
                FutureBuilder(
                  future: friends(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != false &&
                          snapshot.data.toString() != "[]") {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, i) {
                              if (i == 0) {
                                return Column(
                                  children: [
                                    RecentlyPlayedTitle(widget.user, "Friends"),
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: 26.0, top: 26),
                                      height: 2,
                                      color: root["colors"]["grey"],
                                    ),
                                    AddFriend(),
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: 26.0, top: 26),
                                      height: 2,
                                      color: root["colors"]["grey"],
                                    ),
                                    FriendContainer(snapshot.data[i]),
                                  ],
                                );
                              }
                              return FriendContainer(snapshot.data[i]);
                            });
                      }
                      return Column(
                        children: [
                          RecentlyPlayedTitle(widget.user, "Friends"),
                          Container(
                            margin: EdgeInsets.only(bottom: 26.0, top: 26),
                            height: 2,
                            color: root["colors"]["grey"],
                          ),
                          AddFriend(),
                          Container(
                            margin: EdgeInsets.only(bottom: 26.0, top: 26),
                            height: 2,
                            color: root["colors"]["grey"],
                          ),
                          Container(
                            child: Text(
                              "No friends were found",
                              style: googleText(
                                  "text", root["colors"]["light-grey"]),
                            ),
                          ),
                        ],
                      );
                    }
                    return RecentlyPlayedLoading();
                  },
                ),
                if (friend_not_found == true)
                  Positioned(
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      height: 60,
                      width: MediaQuery.of(context).size.width - 52,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.red),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                            ),
                            child:
                                Icon(Icons.error_rounded, color: Colors.white),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text(
                                "No user found",
                                style: googleText("text"),
                              ))
                        ],
                      ),
                    ),
                  )
              ],
            );
          }),
    );
  }
}

class FriendContainer extends StatelessWidget {
  final data_;
  FriendContainer(this.data_);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: friendsSpotify(data_, auth_code),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onDoubleTap: () async {
              var preferences = await prefs();
              var friends = preferences.getStringList("friends");
              var friend_id =
                  snapshot.data["external_urls"]["spotify"].indexOf("/user/");
              friends.remove(snapshot.data["external_urls"]["spotify"]
                  .substring(friend_id + "/user/".length));
              preferences.setStringList("friends", friends);
              friend_controller.add(true);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircleAvatar(
                        foregroundImage:
                            NetworkImage(snapshot.data["images"][0]["url"])),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data["display_name"],
                          overflow: TextOverflow.ellipsis,
                          style: googleText("text"),
                        ),
                        Text("Listening to...",
                            overflow: TextOverflow.ellipsis,
                            style: googleText(
                                "text", root["colors"]["light-grey"])),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return RecentlyPlayedLoading();
      },
    );
  }
}

class AddFriend extends StatelessWidget {
  var size = 50.0;
  final controller_ = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            height: size,
            padding: EdgeInsets.only(left: 20, right: 45),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: root["colors"]["light-grey"], width: 3),
            ),
            child: CupertinoTextField(
                controller: controller_,
                decoration: BoxDecoration(
                  border: null,
                ),
                style: TextStyle(color: Colors.white, fontSize: 22),
                placeholderStyle: TextStyle(
                    color: root["colors"]["light-grey"], fontSize: 22),
                placeholder: "spotify share url"),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              var res = await requests.get(Uri.parse(controller_.text));
              if (res.statusCode == 200) {
                var preferences = await prefs();
                var friends = preferences.getStringList("friends");
                var index = controller_.text.indexOf("/user/");
                var friend_id = controller_.text.substring(
                    index + "/user/".length, controller_.text.indexOf("?si="));
                if (friends.indexOf(friend_id) == -1) {
                  friends.add(friend_id);
                  preferences.setStringList("friends", friends);
                  friend_controller.add(true);
                } else {
                  print("user already a friend");
                }
              } else {
                print("invalid user");
              }
            } catch (e) {
              print("invalid uri");
            }
          },
          child: Container(
            margin: EdgeInsets.only(left: 10),
            height: size,
            width: size,
            decoration: BoxDecoration(
                color: root["colors"]["green"],
                borderRadius: BorderRadius.circular(size)),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: size / 1.7,
            ),
          ),
        )
      ],
    );
  }
}

friends() async {
  var preferences = await prefs();
  var friends_list = preferences.getStringList("friends");
  return friends_list != null ? friends_list : false;
}
