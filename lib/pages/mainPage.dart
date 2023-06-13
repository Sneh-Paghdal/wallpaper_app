import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/tabs/browseTab.dart';
import 'package:wallpaperapp/tabs/searchTab.dart';
import 'detailPage.dart';
import '../constDetails.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;



  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();

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
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  browseTab(),
                  searchTab()
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
