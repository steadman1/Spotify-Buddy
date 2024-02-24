import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_buddy/main.dart';

StreamController streamcontroller = StreamController();

class InputField extends StatefulWidget {
  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final _controller = TextEditingController();
  var flash = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 80,
          padding: EdgeInsets.only(left: 20, right: 45),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey, width: 3),
          ),
          child: CupertinoTextField(
              onChanged: (code) async {
                try {
                  var res = await postSpotify(code);
                  if (code == "") {
                    flash = "";
                  } else if (res != false) {
                    flash = "✅";
                    streamcontroller.add({
                      "color": root["colors"]["green"],
                      "code": res,
                    });
                  } else if (!res) {
                    flash = "❌";
                    streamcontroller.add({
                      "color": Colors.red,
                      "code": null,
                    });
                  } else {
                    flash = "💀";
                    streamcontroller.add({
                      "color": Colors.red,
                      "code": null,
                    });
                  }
                  setState(() {});
                } catch (e) {
                  print(e);
                }
              },
              decoration: BoxDecoration(
                border: null,
              ),
              style: TextStyle(color: Colors.grey, fontSize: 24),
              placeholderStyle: TextStyle(color: Colors.grey, fontSize: 24),
              placeholder: "paste code here"),
        ),
        Positioned(
          right: 20,
          top: 24,
          child: Text(
            flash,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
