import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaperapp/constDetails.dart';

import 'detailPage.dart';

class favorite_page extends StatefulWidget {
  const favorite_page({Key? key}) : super(key: key);

  @override
  State<favorite_page> createState() => _favorite_pageState();
}

class _favorite_pageState extends State<favorite_page> {
  List<dynamic> savedList = [];

  @override
  void initState() {
    fetchSP();
    super.initState();
  }

  fetchSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedString = prefs.getString("savedList") ?? null;
    if(savedString != null){
      setState(() {
        savedList = jsonDecode(savedString);
      });
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 3));
      fetchSP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contants.primaryColor,
      appBar: AppBar(
        backgroundColor: contants.primaryColor,
        title: Text("Favorites",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: (savedList.length == 0) ? Center(
        child: Container(
          height: 115,
          child: Column(
            children: [
              Icon(Icons.heart_broken_rounded,color: Colors.pinkAccent,size: 80,),
              Container(height: 15,),
              Text("You didn't like anything",style: TextStyle(color: Colors.grey),),
            ],
          ),
        ),
      ) :
      // Container(
      //   child: ListView.builder(itemBuilder: (context,index){
      //     return Container(
      //       margin: EdgeInsets.only(top: 10,left: 10,right: 10),
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(10),
      //         border: Border.all(color: Colors.grey,width: 0.5),
      //       ),
      //       child: Row(
      //         children: [
      //           Container(
      //             margin: EdgeInsets.all(10),
      //             height: 100,
      //             width: 100,
      //             decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(10),
      //               image: DecorationImage(
      //                 image: NetworkImage("${savedList[index]['image']}"),
      //                 fit: BoxFit.cover,
      //               )
      //             ),
      //           ),
      //         ],
      //       ),
      //     );
      //   },itemCount: savedList.length,),
      // ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: LiquidPullToRefresh(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: _refresh,
          showChildOpacityTransition : false,
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemCount: savedList.length,
            itemBuilder: (context, index) {
              if(index == savedList.length){
                return SizedBox(
                  width: 30,
                  height: 30,
                  child: FittedBox(child: CircularProgressIndicator(color: Colors.black,backgroundColor: Colors.white,strokeWidth: 6,),),
                );
              }
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            imageUrl:
                            savedList[index]['image'],
                            photographer: savedList[index]['photographer'],
                            photographerUrl: savedList[index]['photographer_url'],
                            potraitImagurl: savedList[index]['portraitImg'],
                            id: savedList[index]['id'].toString(),
                            width: savedList[index]['width'],
                            height: savedList[index]['height'],
                            // 'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}.jpg',
                          ),
                        ),
                      );
                      // print('https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        fadeInDuration:Duration(milliseconds: 0),
                        imageUrl: savedList[index]['image'],
                        // 'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}.jpg',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => AspectRatio(
                          // aspectRatio: (800 + index) / ((index % 2 + 1) * 970),
                          aspectRatio:  savedList[index]['width']/savedList[index]['height'],
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
          ),
        ),
      ),
    );
  }
}
