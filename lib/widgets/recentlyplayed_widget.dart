import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_buddy/main.dart';
import 'dart:math' as math;
import 'package:spotify_buddy/widgets/recentlyplayedloading_widget.dart';

var artists = (item) {
  var artists = "";
  if (item["artists"][0]["name"] != null) {
    for (var i = 0; i < item["artists"].length; i++) {
      artists +=
          "${item["artists"][i]["name"]}${item["artists"].length - 1 != i ? ", " : ""}";
    }
  }
  return artists; //artists;
};

class RecentlyPlayedView extends StatelessWidget {
  final data;
  RecentlyPlayedView(this.data);

  var player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data["recently-played"].containsKey("items")
            ? data["recently-played"]["items"].length
            : 0,
        itemBuilder: (BuildContext context, var i) {
          var item = data["recently-played"]["items"][i];
          if (i == 0) {
            return Column(
              children: [
                RecentlyPlayedTitle(data, "Recent Tracks"),
                data["currently-playing"] != null 
                    ? data["currently-playing"]["item"] != null ? CurrentlyPlaying(data["currently-playing"]) : Container()
                    : Container(),
                CurrentlyPlayingSeparator(false),
                SongContainerView(item, player, i), // player),
              ],
            );
          }
          return SongContainerView(item, player, i);
        });
  }
}

class SongContainerView extends StatelessWidget {
  final item;
  final player;
  final iteration;
  SongContainerView(this.item, this.player, this.iteration);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 140;
    return GestureDetector(
      onTap: () async {
        await player.setUrl(item["track"]["preview_url"]);
        await player.play();
      },
      onDoubleTap: () async => await player.stop(),
      child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: iteration % 2 == 0
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                item["track"]["album"]["images"][1]["url"])),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0, 0.3),
                              end: Alignment(0, 1),
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.78)
                              ]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item["track"]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: googleText("text"),
                            ),
                            Row(
                              children: [
                                item["track"]["explicit"]
                                    ? Icon(
                                        Icons.explicit,
                                        color: Colors.grey,
                                      )
                                    : Container(),
                                Flexible(
                                  child: Text(artists(item["track"]),
                                      overflow: TextOverflow.ellipsis,
                                      style: googleText("text", Colors.grey)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: CustomPaint(
                        size: Size(70, 125),
                        painter: ArrowPainterRight(),
                      ),
                    )
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: CustomPaint(
                        size: Size(70, 125),
                        painter: ArrowPainterLeft(),
                      ),
                    ),
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                item["track"]["album"]["images"][1]["url"])),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0, 0.3),
                              end: Alignment(0, 1),
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.78)
                              ]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item["track"]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: googleText("text"),
                            ),
                            Row(
                              children: [
                                item["track"]["explicit"]
                                    ? Icon(
                                        Icons.explicit,
                                        color: Colors.grey,
                                      )
                                    : Container(),
                                Flexible(
                                  child: Text(artists(item["track"]),
                                      overflow: TextOverflow.ellipsis,
                                      style: googleText("text", Colors.grey)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}

class ArrowPainterRight extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawLine(Offset(0, 0), Offset(35, 0), paint);
    canvas.drawArc(Offset(20, 0) & Size(30, 30), 0, -math.pi / 2, false, paint);
    canvas.drawLine(Offset(50, 15), Offset(50, 125), paint);
    canvas.drawLine(Offset(51, 125), Offset(30, 110), paint);
    canvas.drawLine(Offset(49, 125), Offset(70, 110), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ArrowPainterLeft extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawLine(Offset(70, 0), Offset(35, 0), paint);
    canvas.drawArc(
        Offset(20, 0) & Size(30, 30), -math.pi / 2, -math.pi / 2, false, paint);
    canvas.drawLine(Offset(20, 15), Offset(20, 125), paint);
    canvas.drawLine(Offset(19, 125), Offset(40, 110), paint);
    canvas.drawLine(Offset(21, 125), Offset(1, 110), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RecentlyPlayedTitle extends StatelessWidget {
  final data;
  final title;
  RecentlyPlayedTitle(this.data, this.title);

  @override
  Widget build(BuildContext context) {
    var pfp = false;
    if (!data["user"]["images"].isEmpty) {
      pfp = true;
    }
    return Container(
        margin: EdgeInsets.only(bottom: 10, top: 52),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: googleText("subtitle"),
            ),
            CircleAvatar(
              foregroundImage: NetworkImage(pfp
                  ? data["user"]["images"][0]["url"]
                  : "https://lh3.googleusercontent.com/proxy/QUIekwrHaelCi2KNyFaZRBNMEL_hpw9Fe_U8HSTE0BVmozRlzXFExAPrxmW7-vD2d_v-YRcg8LP_v4HCUXwNFAF2Lg"),
              backgroundColor: root["colors"]["green"],
            ),
          ],
        ));
  }
}

class CurrentlyPlaying extends StatelessWidget {
  final playing;
  CurrentlyPlaying(this.playing);

  @override
  Widget build(BuildContext context) {
    final size = 2 * MediaQuery.of(context).size.width / 3;
    return Column(
      children: [
        CurrentlyPlayingSeparator(true),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            image: DecorationImage(
                image:
                    NetworkImage(playing["item"]["album"]["images"][1]["url"])),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(0, 0.3),
                  end: Alignment(0, 1),
                  colors: [Colors.transparent, Colors.black.withOpacity(0.78)]),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  playing["item"]["name"],
                  overflow: TextOverflow.ellipsis,
                  style: googleText("text"),
                ),
                Row(
                  children: [
                    playing["item"]["explicit"]
                        ? Icon(
                            Icons.explicit,
                            color: Colors.grey,
                          )
                        : Container(),
                    Flexible(
                      child: Text(artists(playing["item"]),
                          overflow: TextOverflow.ellipsis,
                          style: googleText("text", Colors.grey)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CurrentlyPlayingSeparator extends StatelessWidget {
  final current;
  CurrentlyPlayingSeparator(this.current);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 26),
          height: 2,
          color: root["colors"]["grey"],
        ),
        Container(
          margin: EdgeInsets.only(top: 6, bottom: 26),
          child: Text(
            current ? "currently playing" : "recently played",
            style: googleText("subtext", root["colors"]["light-grey"]),
          ),
        ),
      ],
    );
  }
}
