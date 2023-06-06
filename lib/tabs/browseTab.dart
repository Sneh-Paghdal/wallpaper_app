import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/constDetails.dart';

import '../pages/detailPage.dart';

class browseTab extends StatefulWidget {
  const browseTab({Key? key}) : super(key: key);

  @override
  State<browseTab> createState() => _browseTabState();
}

class _browseTabState extends State<browseTab> {

  List<dynamic> imageArr = [];

  getImages() async {
    var headers = {
      'Authorization': 'U35FeBRTdDYbSgBgCR9hRaeMvfdhKfOkkX9PPUGbq9v7IFnw7KFiiOPM'
    };
    var request = http.Request('GET', Uri.parse('https://api.pexels.com/v1/curated?per_page=50'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);
      setState(() {
        imageArr = json['photos'];
      });
      // print(imageArr);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImages();
  }

  Future<void> _refresh()async {
    await Future.delayed(Duration(seconds: 2),(){
      getImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: imageArr.length != 0 ? MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: imageArr.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        imageUrl:
                        imageArr[index]['src']['original'],
                        // 'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}.jpg',
                      ),
                    ),
                  );
                  // print('https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageArr[index]['src']['original'],
                    // 'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}.jpg',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AspectRatio(
                      // aspectRatio: (800 + index) / ((index % 2 + 1) * 970),
                      aspectRatio:  imageArr[index]['width']/imageArr[index]['height'] ,
                      child: Container(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // child: Image.network(imageArr[index]['src']['original']),
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.more_horiz,
                  color: contants.primaryFontColor,
                  size: 20,
                ),
              )
            ],
          );
        },
      ) : Container(child: Text("Loading",style: TextStyle(color: Colors.white),),),
    );
  }
}

