import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaper/wallpaper.dart';


class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.imageUrl, required this.photographer, required this.photographerUrl, required this.potraitImagurl, required this.id});
  final String imageUrl;
  final String photographer;
  final String photographerUrl;
  final String potraitImagurl;
  final String id;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  void initState() {
    isSaved();
    super.initState();
  }

  List<dynamic> savedList = [];

  isSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedListSt = prefs.getString("savedList");
    if(savedListSt != null ){
      print(savedListSt);
      savedList = jsonDecode(savedListSt!);
      for(int i = 0; i < savedList.length; i++){
        if(widget.id == savedList[i]['id']){
          setState(() {
            isPhotoSaved = true;
          });
          break;
        }
        setState(() {
          isPhotoSaved = false;
        });
      }
    }
    print("List" + savedList.toString());
  }

  saveImg() async {
    setState(() {
      isLoading = true;
    });
    var obj = {
      "id" : widget.id,
      "image" : widget.imageUrl,
      "portraitImg" : widget.potraitImagurl,
      "photographer" : widget.photographer,
      "photographer_url" : widget.photographerUrl
    };
    savedList.add(obj);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedListSt = jsonEncode(savedList);
    prefs.setString("savedList", savedListSt);
    showToast(context, "Liked!", false, Colors.black, 100);
    setState(() {
      isLoading = false;
      isPhotoSaved = true;
    });
  }

  unSaveImage() async {
    setState(() {
      isLoading = true;
    });
    bool isSaved = false;
    int indexOfSavedImg = 0;
    for(int i = 0; i < savedList.length; i++){
      if(widget.id == savedList[i]['id']){
          isSaved = true;
          indexOfSavedImg = i;
        break;
      }
    }
    if(isSaved == true){
      savedList.removeAt(indexOfSavedImg);
      print(savedList);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('savedList');
      String savedListSt = jsonEncode(savedList);
      prefs.setString("savedList", savedListSt);
      showToast(context, "Like removed!", false, Colors.black, 100);
      setState(() {
        isPhotoSaved = false;
      });
    }
    setState(() {
      isLoading = false;
      isPhotoSaved = false;
    });
  }

    bool isPhotoSaved = false;
    bool isFullScreen = false;
    bool isLoading = false;
    String home = "Home Screen",
        lock = "Lock Screen",
        both = "Both Screen",
        system = "System";

  @override
  Widget build(BuildContext context) {
    return (isFullScreen == true) ? fullScareen() : miniMizedScreen();
  }

  Widget miniMizedScreen(){

    final MethodChannel _channel = MethodChannel('wallpaper_channel');

    Future<void> setWallpaperKt(String imagePath) async {
      try {
        await _channel.invokeMethod('setWallpaper', {'imagePath': imagePath});
      } catch (e) {
        // Handle any exceptions that occur during the method invocation
        print('Failed to set wallpaper: $e');
      }
    }


    bool _isDisable = true;
    late Stream<String> progressString;
    late String res;
    bool downloading = false;

    void onSteWallpaper(context){
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  child: Container(
                    margin: EdgeInsets.only(left: 40,right: 40,bottom: 30),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10)
                    ),
                    alignment: Alignment.center,
                    height: 210,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 20,),
                        InkWell(
                          onTap: _isDisable
                              ? null
                              : () async {
                            var width = MediaQuery.of(context).size.width;
                            var height = MediaQuery.of(context).size.height;
                            home = await Wallpaper.homeScreen(
                                options: RequestSizeOptions.RESIZE_FIT,
                                width: width,
                                height: height);
                            setState(() {
                              downloading = false;
                              home = home;
                            });
                            Navigator.pop(context);
                            print("Task Done");
                          },
                          child: Text("Home Screen",style: GoogleFonts
                              .notoSans(color: Colors.white,fontSize: 15),),
                        ),
                        Container(height: 20,),
                        InkWell(
                          onTap: _isDisable
                              ? null
                              : () async {
                            lock = await Wallpaper.lockScreen();
                            setState(() {
                              downloading = false;
                              lock = lock;
                            });
                            Navigator.pop(context);
                            print("Task Done");
                          },
                          child: Text("Lock Screen",style: GoogleFonts
                              .notoSans(color: Colors.white,fontSize: 15),),
                        ),
                        Container(height: 20,),
                        InkWell(
                          onTap: _isDisable
                              ? null
                              : () async {
                            both = await Wallpaper.bothScreen();
                            setState(() {
                              downloading = false;
                              both = both;
                            });
                            Navigator.pop(context);
                            print("Task Done");
                          },
                          child: Text("Home & Lock Screen",style: GoogleFonts
                              .notoSans(color: Colors.white,fontSize: 15),),
                        ),
                        Container(height: 10,),
                        Divider(
                          color: Colors.grey,
                          indent: 20,
                          endIndent: 20,
                          thickness: 1,
                        ),
                        Container(height: 10,),
                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",style: GoogleFonts
                              .notoSans(color: Colors.white,fontSize: 15),),
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      );
    }

    Future<void> dowloadImage(BuildContext context) async {
      setState(() {
        isLoading = true;
      });
      progressString = Wallpaper.imageDownloadProgress(
          widget.potraitImagurl
      );
      progressString.listen((data) {
        setState(() {
          res = data;
          downloading = true;
        });
        print("DataReceived: " + data);
      }, onDone: () async {
        setState(() {
          downloading = false;
          _isDisable = false;
        });
        setState(() {
          isLoading = false;
        });
        onSteWallpaper(context);
        print("Task Done");
      }, onError: (error) {
        setState(() {
          downloading = false;
          _isDisable = true;
        });
        setState(() {
          isLoading = false;
        });
        showToast(context, "Something went wrong", true, Colors.red, 100);
        print("Some Error");
      });
    }
    
    shareImage(imageUrl) async {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse(imageUrl);
      final res = await http.get(url);
      final bytes = res.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      print(path);
      File(path).writeAsBytesSync(bytes);
      setState(() {
        isLoading = false;
      });
      // await Share.shareWithResult("ABC is BCD");
      // await Share.shareFiles([path],text: "",subject: "");
      Share.shareFiles([path],);
    }

    downloadFile(String url) async {
      setState(() {
        isLoading = true;
      });
      print(url);
      FileDownloader.downloadFile(url: url,
          onDownloadCompleted: (val){
            print("Downloader");
            setState(() {
              isLoading = false;
            });
            showToast(context, 'Image Downloaded in downloads', true, Colors.black, 100);
          },
          onDownloadError: (e){
            var snackBar = SnackBar(content: Text('Error Occur due to: $e'),backgroundColor: Colors.red,);
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print("Failed");
          }
      );
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

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onDoubleTap: (){
                saveImg();
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.imageUrl),
                    // colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.screen),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.2),
                                child: const Icon(
                                  CupertinoIcons.chevron_back,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
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
                                                              Uri.parse(widget
                                                                  .photographerUrl)
                                                          );
                                                        },
                                                        child: Text(
                                                          'Clicked by ${widget
                                                              .photographer}',
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
                                                                    text: widget
                                                                        .imageUrl));
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
                                                          downloadFile(
                                                              widget.potraitImagurl);
                                                        },
                                                        child: Text(
                                                          'Download image',
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
                                        }
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                );
                              },
                              child: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                if(isFullScreen == false){
                                  isFullScreen = true;
                                }
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.8),
                              child: Icon(
                                CupertinoIcons.viewfinder,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                    child: (isLoading == true) ? LinearProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                      minHeight: 3,
                    ) : Container(height: 3,color: Colors.black,)
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                    left: 18,
                    right: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (isPhotoSaved == false)?
                      InkWell(
                        onTap: (){
                          saveImg();
                        },
                        child: Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              // color: Colors.pinkAccent,
                            ),
                            child: const Icon(CupertinoIcons.heart_circle_fill,color: Colors.white,size: 30,)),
                      )
                      :
                      InkWell(
                        onTap: (){
                          unSaveImage();
                        },
                        child: Container(
                          height: 30,
                            width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.pinkAccent,
                            ),
                            child: const Icon(CupertinoIcons.heart_circle_fill,color: Colors.white,size: 30,)),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              setWallpaperKt(widget.imageUrl);
                              // return await dowloadImage(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17, vertical: 15),
                              decoration: BoxDecoration(
                                // color: const Color(0xFFF1F1F1),
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Set Wallpaper',
                                style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          InkWell(
                            onTap: (){
                              downloadFile(
                                  widget.potraitImagurl);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17, vertical: 15),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Save',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                          onTap: (){
                            shareImage(widget.imageUrl);
                          },
                          child: const Icon(Icons.share,color: Colors.white,)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fullScareen(){
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
                padding: EdgeInsets.only(right: 20,bottom: 20),
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: (){
                    setState(() {
                      isFullScreen = false;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    child: Icon(CupertinoIcons.arrow_down_right_arrow_up_left,
                      color: Colors.white,
                    ),
                  ),
                ),
          )
          )
        ],
      ),
    );
  }
}

void showToast(BuildContext context,message,bool isBottomsheet,Color color,int height) {

  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(
      duration: Duration(seconds: 1),
      // margin: EdgeInsets.only(top: 100),
      margin: EdgeInsets.only(bottom: isBottomsheet == false ? MediaQuery.of(context).size.height-height : 20,left: 10,right: 10),
      backgroundColor: color,
      content: Text(message,style: TextStyle(color: Colors.white),),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

