import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_buddy/main.dart';
import 'package:spotify_buddy/widgets/inputfield_widget.dart';

var button_text = "Connect Account";
var buttonPress =
    () async => await canLaunch(url_) ? await launch(url_) : print("rip");

class SpotifyAuthButton extends StatefulWidget {
  @override
  _SpotifyAuthButtonState createState() => _SpotifyAuthButtonState();
}

class _SpotifyAuthButtonState extends State<SpotifyAuthButton> {
  Stream stream_ = streamcontroller.stream;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        buttonPress();
      },
      child: StreamBuilder(
          stream: stream_,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            buttonHandler(snapshot.data, context);
            return AnimatedContainer(
              duration: Duration(milliseconds: 700),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: snapshot.data != null
                    ? snapshot.data["color"]
                    : Colors.grey,
              ),
              width: double.infinity,
              height: 100,
              child: Center(
                  child: Text(
                button_text,
                style: googleText("subtitle"),
              )),
            );
          }),
    );
  }
}

buttonHandler(data, context) {
  if (data != null) {
    if (data["code"] != null) {
      button_text = "Finish";
      buttonPress = () => Navigator.pushNamed(
            context,
            "/welcome",
            arguments: data["code"],
          );
    } else {
      button_text = "Link Spotify";
      buttonPress =
          () async => await canLaunch(url_) ? await launch(url_) : print("rip");
    }
  }
}
