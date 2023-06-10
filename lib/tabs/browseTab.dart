import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaperapp/constDetails.dart';
import '../pages/detailPage.dart';

class browseTab extends StatefulWidget {
  const browseTab({Key? key}) : super(key: key);

  @override
  State<browseTab> createState() => _browseTabState();
}

class _browseTabState extends State<browseTab> {

  List<dynamic> imageArr = [];
  late ScrollController _scrollController;
  final int maxLength = 10000;
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;

  getImages() async {

    setState(() {
      isLoading = true;
    });

    var headers = {
      'Authorization': contants.apiKey
    };
    var request = http.Request('GET', Uri.parse('https://api.pexels.com/v1/curated?per_page=10&page=${page}'));
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
    getImages();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95 && !isLoading ){
        if(hasMore){
          getImages();
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

  Future<void> _launchInBrowser(Uri url) async {
    setState(() {
      isLoading = true;
    });
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
    setState(() {
      isLoading = false;
    });
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
                        potraitImagurl: imageArr[index]['src']['portrait'],
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
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                              return SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 12, vertical: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  FontAwesomeIcons
                                                      .xmark),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Text(
                                                'Options',
                                                style: GoogleFonts
                                                    .notoSans(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              _launchInBrowser(
                                                  Uri.parse(imageArr[index]['photographer_url'])
                                              );
                                            },
                                            child: Text(
                                              'Clicked by ${imageArr[index]['photographer']}',
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                              style: GoogleFonts
                                                  .notoSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight
                                                    .w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              try {
                                                await Clipboard.setData(
                                                    ClipboardData(
                                                        text: imageArr[index]['src']['original']));
                                                showToast(
                                                    context, "Link Copied!",
                                                    true, Colors.black,
                                                    100);
                                              } catch (e) {
                                                print(e);
                                                showToast(
                                                    context, "${e}",
                                                    false, Colors.black,
                                                    100);
                                              }
                                            },
                                            child: Text(
                                              'Copy link',
                                              style: GoogleFonts
                                                  .notoSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight
                                                    .w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Share.share(imageArr[index]['src']['original']);
                                            },
                                            child: Text(
                                              'Share link',
                                              style: GoogleFonts
                                                  .notoSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight
                                                    .w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.more_horiz,
                    color: contants.primaryFontColor,
                    size: 20,
                  ),
                ),
              )
            ],
          );
        },
      ) : Container(child: Center(child: CircularProgressIndicator(backgroundColor:Colors.white,color: Colors.black,strokeWidth:6)),),
    );
  }
}

