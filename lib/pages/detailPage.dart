import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.imageUrl, required this.photographer, required this.photographerUrl});
  final String imageUrl;
  final String photographer;
  final String photographerUrl;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

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
            var snackBar = SnackBar(content: Text('File downloaded. Saved to Downloads'),backgroundColor: Colors.green,);
            print("Downloader");
            setState(() {
              isLoading = false;
            });
            showToast(context, 'File downloaded. Saved to: $val', false, Colors.green, 150);
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
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.imageUrl),
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
                                            Container(
                                              margin: EdgeInsets.only(left: 15,
                                                  right: 15,
                                                  top: 0.5),
                                              child: (isLoading == true)
                                                  ? LinearProgressIndicator(
                                                backgroundColor: Colors.white,
                                                valueColor: AlwaysStoppedAnimation(
                                                    Colors.red),
                                                minHeight: 3,
                                              )
                                                  : Container(height: 3,),
                                            ),
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
                                                      try {
                                                        await Clipboard.setData(
                                                            ClipboardData(
                                                                text: widget
                                                                    .imageUrl));
                                                        showToast(
                                                            context, "Copied!",
                                                            false, Colors.black,
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
                                                      downloadFile(
                                                          widget.imageUrl);
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
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: const Icon(
                          CupertinoIcons.viewfinder,
                          color: Colors.black,
                        ),
                      )
                    ],
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
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(Colors.red),
                    minHeight: 3,
                  ) : Container(height: 3,)
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                    left: 18,
                    right: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(CupertinoIcons.heart_circle_fill),
                      Row(
                        children: [
                          InkWell(
                            onTap: (){

                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17, vertical: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Set Wallpaper',
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          InkWell(
                            onTap: (){
                              // downloadFile(imageUrl);
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
                          print("Tapping Tapping");
                          shareImage(widget.imageUrl);
                        },
                          child: const Icon(Icons.share)),
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

