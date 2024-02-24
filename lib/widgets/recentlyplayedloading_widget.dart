import 'package:flutter/material.dart';
import 'package:spotify_buddy/main.dart';

class RecentlyPlayedLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                root["colors"]["green"])),
        FutureBuilder(
            future:
                Future.delayed(Duration(seconds: 7), () => true),
            builder:
                (BuildContext context, AsyncSnapshot snapshot) {
              return AnimatedOpacity(
                opacity: snapshot.data != null ? 1.0 : 0.0,
                duration: Duration(milliseconds: 150),
                child: Container(
                  margin: EdgeInsets.only(top: 26),
                  child: Text(
                    "still loading...",
                    style: googleText("text"),
                  ),
                ),
              );
            })
      ],
    );
  }
}