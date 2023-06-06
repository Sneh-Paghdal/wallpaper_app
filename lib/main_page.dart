import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'detail_page.dart';
import 'const_details.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> imageArr = [];

  getImages() async {
    var headers = {
      'Authorization': 'U35FeBRTdDYbSgBgCR9hRaeMvfdhKfOkkX9PPUGbq9v7IFnw7KFiiOPM'
    };
    var request = http.Request('GET', Uri.parse('https://api.pexels.com/v1/curated?per_page=40'));
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
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
    getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contants.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: TabBar(
                tabs: [
                  Container(
                    height: 20,
                    alignment: Alignment.center,
                    child: const Text(
                      'Browse',
                      style: TextStyle(color: contants.primaryFontColor,),
                    ),
                  ),
                  Container(
                    height: 20,
                    alignment: Alignment.center,
                    child: const Text(
                      'Search',
                      style: TextStyle(color: contants.primaryFontColor,),
                    ),
                  ),
                ],
                labelPadding: const EdgeInsets.only(bottom: 5),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 25),
                indicatorWeight: 4,
                indicatorColor: contants.primaryFontColor,
                labelColor: contants.primaryFontColor,
                unselectedLabelColor: contants.primaryFontColor,
                controller: _tabController,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: MasonryGridView.count(
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
                                      // imageArr[index]['src']['original'],
                                        'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}',
                                  ),
                                  ),
                                );
                                print('https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}');
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  // imageArr[index]['src']['original'],
                                  'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => AspectRatio(
                                    aspectRatio:
                                    (800 + index) / ((index % 2 + 1) * 970),
                                    child: Container(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
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
                  Center(
                    child: Container(
                      child: Text("Second Screen",style: TextStyle(color: contants.primaryFontColor),),
                    ),
                  )
                ],
              ),
            ),
            // Container(
            //   height: 30,
            //   color: Colors.white,
            //   padding: const EdgeInsets.symmetric(horizontal: 70),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Icon(FontAwesomeIcons.house),
            //       Icon(
            //         FontAwesomeIcons.magnifyingGlass,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       Icon(
            //         FontAwesomeIcons.plus,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       Icon(
            //         CupertinoIcons.chat_bubble_fill,
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       CircleAvatar(
            //         radius: 12,
            //         backgroundColor: Theme.of(context).primaryColor,
            //         backgroundImage: const CachedNetworkImageProvider(
            //             'https://picsum.photos/100'),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
