import 'package:flutter/material.dart';
import 'package:spotify_buddy/main.dart';
import 'package:spotify_buddy/widgets/inputfield_widget.dart';
import 'package:spotify_buddy/widgets/spotifyauth_widget.dart';

class SpotifyRegister extends StatelessWidget {
  final transfer;
  final bottom_view_insets;
  SpotifyRegister(this.bottom_view_insets, this.transfer);

  @override
  Widget build(BuildContext context) {
    if (transfer != false) {
      apiSpotify({"refresh_token": transfer}, true)
          .then((data) {
        if (data) {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            "/home",
            arguments: data,
          );
        }
      }).onError((error, stackTrace) {
        print(error);
      });
    }
    //transfer = false;
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.only(left: 26.0, right: 26.0),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  child: Text(
                "Connect your\nAccount.",
                style: googleText("title"),
              )),
              InputField(),
              SpotifyAuthButton(),
            ],
          ),
        ),
      ),
    ));
  }
}
