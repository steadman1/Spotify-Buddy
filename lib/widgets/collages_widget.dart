import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart';
import 'package:spotify_buddy/widgets/recentlyplayed_widget.dart';
import 'package:spotify_buddy/widgets/recentlyplayedloading_widget.dart';
import '../main.dart';

class CollagesView extends StatefulWidget {
  final data;
  CollagesView(this.data);

  @override
  _CollagesViewState createState() => _CollagesViewState();
}

class _CollagesViewState extends State<CollagesView>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  void initState() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 26.0, right: 26.0),
      child: Column(
        children: [
          RecentlyPlayedTitle(widget.data, "Album Collages"),
          Container(
            margin: EdgeInsets.only(bottom: 26.0, top: 26.0),
            height: 2,
            color: root["colors"]["grey"],
          ),
          TabBar(
            indicatorColor: root["colors"]["green"],
            tabs: [
              Tab(
                text: "Short Term",
              ),
              Tab(
                text: "Long Term",
              ),
              Tab(
                text: "All Time",
              )
            ],
            controller: tabController,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 26.0, top: 26.0),
            height: 2,
            color: root["colors"]["grey"],
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                TermTab(widget.data["short-albums"]),
                TermTab(widget.data["long-albums"]),
                TermTab(widget.data["all-albums"]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollageContainer extends StatelessWidget {
  final data;
  CollageContainer(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(data["size"] + " ${data["range"]}",
              style: googleText("text")),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 26.0),
          child: Image.memory(data["result"]),
        ),
      ],
    );
  }
}

mergeImages(images, grids) async {
  var memory_images = [];
  final size = 300.0;
  for (var grid in grids) {
    final options = ImageMergeOption(
      canvasSize: Size(size * grid, size * grid),
      format: OutputFormat.png(),
    );
    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        var file = await DefaultCacheManager().getSingleFile(
            images["items"][y * (grid) + x]["album"]["images"][1]["url"]);
        options.addImage(MergeImageConfig(
            image: MemoryImageSource(file.readAsBytesSync()),
            position: ImagePosition(
              Offset(size * x, size * y),
              Size.square(size),
            )));
      }
    }
    final result = await ImageMerger.mergeToMemory(option: options);
    var arg_start = images["href"].indexOf("time_range=");
    var range = images["href"].substring(arg_start + "time_range=".length);
    memory_images.add({
      "result": result,
      "size":
          grid != 1 ? grid.toString() + "x" + grid.toString() : "Most streams",
      "range": range == "short_term"
          ? "— Short term"
          : range == "long_term"
              ? "— All time"
              : "— Long term",
    });
  }
  return memory_images;
}

class TermTab extends StatelessWidget {
  TermTab(this.data);
  final data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: mergeImages(data, [7, 5, 3, 1]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //print(snapshot.data);
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, index) {
                  return CollageContainer(snapshot.data[index]);
                });
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text("Not enough listens for collages",
                style: googleText("text"));
          }
          return RecentlyPlayedLoading();
        });
  }
}
