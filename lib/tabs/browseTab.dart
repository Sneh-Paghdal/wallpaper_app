import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaperapp/constDetails.dart';
import '../pages/detailPage.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

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

  shareImageWP(String imageUrl) async {
    final url = Uri.parse(imageUrl);
    final res = await http.get(url);
    final bytes = res.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';

    await File(path).writeAsBytes(bytes);
    print("runining");
    final whatsappUrl = "whatsapp://send?text=Check out this image!&phone=&$path";
    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    tutoial();

  }



  tutoial() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.getBool("userIsOld") == true){

      getImages();
      _scrollController = ScrollController();
      _scrollController.addListener(() {
        if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95 && !isLoading ){
          if(hasMore){
            getImages();
          }
        }
      });

    }else{

      showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
        return WillPopScope(
          onWillPop: ()=>Future.value(false),
          child: Theme(
            data: ThemeData.dark(),
            child: AlertDialog(
              title: Text("Please swip right to watch favourite ->"),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context,'cancel');
                  preferences.setBool("userIsOld",true);
                  getImages();
                  _scrollController = ScrollController();
                  _scrollController.addListener(() {
                    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95 && !isLoading ){
                      if(hasMore){
                        getImages();
                      }
                    }
                  });
                },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Set custom color
                    ),
                    child: Text("Ok"))
              ],
            ),
          ),
        );
      });

    }



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

  bool _menuActive = false;

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      onMenuToggle: (active) {
        setState(() => _menuActive = active);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: imageArr.length != 0 ? LiquidPullToRefresh(
            // height:50,
            // borderWidth:5,
          color:Colors.black,
          springAnimationDurationInMilliseconds:950,
          onRefresh: _refresh,
          showChildOpacityTransition : false,
          child: MasonryGridView.count(
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
              return PieMenu(
                actions: [
                  PieAction(
                    buttonTheme: PieButtonTheme(backgroundColor: Colors.black,iconColor: Colors.white),
                    buttonThemeHovered: PieButtonTheme(backgroundColor: Colors.red,iconColor: Colors.white),
                    tooltip: 'Copy Link',
                    onSelect: () async {
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
                    child: const FaIcon(FontAwesomeIcons.copy),
                  ),
                  PieAction(
                    buttonTheme: PieButtonTheme(backgroundColor: Colors.black,iconColor: Colors.white),
                    buttonThemeHovered: PieButtonTheme(backgroundColor: Colors.red,iconColor: Colors.white),
                    tooltip: 'Clicked By ${imageArr[index]['photographer']}',
                    onSelect: () => _launchInBrowser(
                        Uri.parse(imageArr[index]['photographer_url'])
                    ),
                    child: const Icon(Icons.person),
                  ),
                  PieAction(
                    buttonTheme: PieButtonTheme(backgroundColor: Colors.black,iconColor: Colors.white),
                    buttonThemeHovered: PieButtonTheme(backgroundColor: Colors.red,iconColor: Colors.white),
                    tooltip: 'Share',
                    onSelect: () =>  Share.share(imageArr[index]['src']['original']),
                    child: const FaIcon(FontAwesomeIcons.share),
                  ),
                  PieAction(
                    buttonTheme: PieButtonTheme(backgroundColor: Colors.black,iconColor: Colors.white),
                    buttonThemeHovered: PieButtonTheme(backgroundColor: Colors.red,iconColor: Colors.white),
                    tooltip: 'Share to whatsapp',
                    onSelect: () {
                      showToast(context, "Please select whatsapp in this share list", false, Colors.black, 100);
                      Share.share(imageArr[index]['src']['original']);
                    },
                    // onSelect: () =>  shareImageWP(imageArr[index]['src']['original']),
                    child: const FaIcon(FontAwesomeIcons.whatsapp),
                  ),
                ],
                child: Column(
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
                              id: imageArr[index]['id'].toString(),
                              width: imageArr[index]['width'],
                              height: imageArr[index]['height'],
                              // 'https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}.jpg',
                            ),
                          ),
                        );
                        print(imageArr[index]['src']['portrait']);
                        // print('https://picsum.photos/${800 + index}/${(index % 2 + 1) * 970}');
                      },
                      onLongPress: (){},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(

                          fadeInDuration:Duration(milliseconds: 500),
                          fadeOutDuration:Duration(milliseconds: 0),
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
                                                    Icon(
                                                        Icons.close),
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
                ),
              );
            },
          ),
        ) : Container(child: Center(child: CircularProgressIndicator(backgroundColor:Colors.white,color: Colors.black,strokeWidth:6)),),
      ),
    );
  }
}


