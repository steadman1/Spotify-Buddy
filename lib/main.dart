import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_buddy/home_page.dart';
import 'package:spotify_buddy/spotifyregister_page.dart';
import 'package:http/http.dart' as requests;
import 'package:spotify_buddy/widgets/recentlyplayedloading_widget.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: prefs(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: "/spotify-register",
              onGenerateRoute: buildRoute,
            );
          } else if (snapshot.hasError) {
            return ScaffoldBody(SafeArea(child: RecentlyPlayedLoading()));
          }
          return WidgetsApp(
            debugShowCheckedModeBanner: false,
            color: root["colors"]["dark-grey"],
            builder: (context, widget) {
              return RecentlyPlayedLoading();
            },
          );
        });
  }
}

class ScaffoldBody extends StatelessWidget {
  ScaffoldBody(this.child);
  final child;

  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                root["colors"]["dark-grey"],
                root["colors"]["dark-grey"]
              ],
              begin: Alignment(-1, -1),
              end: Alignment(1, 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

postSpotify(code) async {
  requests.Response res =
      await requests.post(Uri.parse(data_spotify["post_url"]), body: {
    "grant_type": data_spotify["grant_type"],
    "code": code,
    "redirect_uri": "http://www.steadmancode.com/spotify",
    "client_secret": data_spotify["client_secret"],
    "client_id": data_spotify["client_id"],
  }, headers: {
    "Charset": "utf-8",
  });
  //print(res.body);
  if (res.statusCode == 200) {
    var body = json.decode(res.body);
    var prefs_ = await prefs();
    auth_code = body["access_token"];
    prefs_.setString("refresh_token", body["refresh_token"]);
    return body;
  }
  return false;
}

refreshSpotify(code) async {
  requests.Response res = await requests
      .post(Uri.parse("https://api.spotify.com/v1/authorize"), body: {
    "code": code,
    "refresh_token": "token"
  }, headers: {
    "Charset": "utf-8",
  });
  //print(res.body);
  if (res.statusCode == 200) {
    var body = json.decode(res.body);
    var prefs_ = await prefs();
    prefs_.setString("refresh_token", body["refresh_token"]);
    return body;
  }
  return false;
}

Future friendsSpotify(userid, code) async {
  var res = await requests
      .get(Uri.parse("https://api.spotify.com/v1/users/${userid}"), headers: {
    "Content-Type": "application/json;charset=UTF-8",
    "Authorization": "Bearer ${code}",
    "Charset": "utf-8",
  });
  if (res.statusCode == 200) {
    var body = json.decode(res.body);
    return body;
  }
  return false;
}

Future apiSpotify(access_token, [refresh = false]) async {
  var headers = {
    "Content-Type": "application/json;charset=UTF-8",
    "Authorization": "Bearer ${access_token["access_token"]}",
    "Charset": "utf-8",
  };
  if (refresh) {
    //print(access_token["refresh_token"]);
    var token_swap = await refreshSpotify(access_token["refresh_token"]);
    if (token_swap != false ? token_swap.statusCode == 200 : false) {
      return json.decode(token_swap);
    }
    return false;
  }

  var recent = await requests.get(
      Uri.parse(
          "https://api.spotify.com/v1/me/player/recently-played?limit=50"),
      headers: headers);

  var me = await requests.get(Uri.parse("https://api.spotify.com/v1/me"),
      headers: headers);

  var playing = await requests.get(
      Uri.parse("https://api.spotify.com/v1/me/player/currently-playing"),
      headers: headers);

  var top_short = await requests.get(
      Uri.parse(
          "https://api.spotify.com/v1/me/top/tracks?time_range=short_term&limit=50"),
      headers: headers);

  var top_long = await requests.get(
      Uri.parse(
          "https://api.spotify.com/v1/me/top/tracks?time_range=medium_term&limit=50"),
      headers: headers);

  var top_all = await requests.get(
      Uri.parse(
          "https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=50"),
      headers: headers);
  
  return {
    "recently-played": json.decode(recent.body),
    "currently-playing": playing.body != "" ? json.decode(playing.body) : null,
    "short-albums": top_short.body != "" ? json.decode(top_short.body) : null,
    "long-albums": top_long.body != "" ? json.decode(top_long.body) : null,
    "all-albums": top_all.body != "" ? json.decode(top_all.body) : null,
    "user": json.decode(me.body),
  };
}

Route<dynamic> buildRoute(RouteSettings settings) {
  var token = prefs_.getString("refresh_token");
  if (settings.name == "/home") {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => ScaffoldBody(Home(settings.arguments, prefs_)),
    );
  } else if (settings.name == "/spotify-register") {
    return MaterialPageRoute(
      builder: (context) => ScaffoldBody(
        SpotifyRegister(MediaQuery.of(context).viewInsets.bottom,
            token != null ? token : false),
      ),
    );
  } else if (settings.name == "/welcome") {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => ScaffoldBody(Welcome(settings.arguments)),
    );
  }
  return null;
}

var auth_code;
var payload = {};
var data_spotify = {
  "post_url": "https://accounts.spotify.com/api/token",
  "client_id": "e651f520ab954f11bf51831fd1d456d7",
  "client_secret": "533c8899de3e41679b5e7d68f9c20ad0",
  "scopes":
      "user-top-read user-read-recently-played user-read-playback-position user-library-read user-read-recently-played user-read-private user-read-currently-playing",
  "grant_type": "authorization_code",
};
var googleText = (name, [color = Colors.white]) => GoogleFonts.poppins(
    fontSize: root["font-sizes"][name],
    fontWeight: root["font-weights"][name],
    height: 1.2,
    color: color);
var prefs = () async {
  var instance = await SharedPreferences.getInstance();
  prefs_ = instance;
  return instance;
};
var prefs_;
var root = {
  "font-sizes": {
    "title": 50.0,
    "subtitle": 28.0,
    "text": 20.0,
    "sub-text": 18.0,
  },
  "font-weights": {
    "title": FontWeight.w700,
    "subtitle": FontWeight.w600,
    "text": FontWeight.w500,
    "sub-text": FontWeight.w500,
  },
  "colors": {
    "dark-grey": Color(0xFF191414),
    "grey": Color(0xFF393636),
    "light-grey": Colors.grey[600],
    "green": Colors.indigo[400],
  }
};
var url_ =
    "https://accounts.spotify.com/authorize/?response_type=code&client_id=${data_spotify["client_id"]}&scope=${Uri.encodeFull(data_spotify["scopes"])}&redirect_uri=http://www.steadmancode.com/spotify";

var collage_sizes = [2, 3, 4, 5];
