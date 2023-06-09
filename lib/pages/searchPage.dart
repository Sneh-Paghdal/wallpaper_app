import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaperapp/constDetails.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/pages/detailPage.dart';
class searchPage extends StatefulWidget {
  String keyword;
  searchPage({super.key,required this.keyword});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {

  TextEditingController searchControl = TextEditingController();
  List<dynamic> imageArr = [];
  late ScrollController _scrollController;
  final int maxLength = 10000;
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;

  getImages(String keyword) async {

    setState(() {
      isLoading = true;
    });

    var headers = {
      'Authorization': contants.apiKey
    };
    var request = http.Request('GET', Uri.parse('https://api.pexels.com/v1/search?query=${keyword}&per_page=10&page=${page}'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);

      for(final e  in json['photos']){
        imageArr.add(e);
      }
      setState(() {

        isLoading = false;
        page = page +1;
        hasMore = imageArr.length < maxLength;
      });
      // print(imageArr);
    }
    else {
      print(response.reasonPhrase);

      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    setState(() {
      searchControl.text = widget.keyword;
    });
    getImages(searchControl.text);
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95 && !isLoading ){
        if(hasMore){
          getImages(searchControl.text);
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement initState
    _scrollController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 90,
          automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50)),
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.only(),
          child: TextField(
            cursorColor:Colors.black,
            controller: searchControl,
            onSubmitted: (value){
              imageArr.clear();
              getImages(value);
            },
            // focusNode: myFocusNode,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 15,bottom: 10,right: 10),
              hintText: 'Search wallpaper...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: IconButton(
                onPressed: () {},
                // onPressed: searchResultProducts,
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
        ),

      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: imageArr.length != 0 ? MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: imageArr.length + (hasMore? 1 : 0),
          itemBuilder: (context, index) {

            if(index == imageArr.length){
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
                          imageArr[index]['src']['original'],
                          photographer: imageArr[index]['photographer'],
                          photographerUrl: imageArr[index]['photographer_url'],
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
        ) : Container(child: Center(child: CircularProgressIndicator(backgroundColor:Colors.white,color: Colors.black,strokeWidth:6)),),
      )
    );
  }
}
