//this is in under production


import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class sliderSection2 extends StatefulWidget {
  const sliderSection2({Key? key}) : super(key: key);

  @override
  State<sliderSection2> createState() => _sliderSection2State();
}

class _sliderSection2State extends State<sliderSection2> {

  var imageArray = [
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
  ];

  final CarouselController _controller = CarouselController();


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              imageArray.length != 0
                  ? CarouselSlider(
                    carouselController: _controller,
                      options: CarouselOptions(
                        aspectRatio: 2832 / 2832,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        pauseAutoPlayOnTouch: true,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          // Handle page change event
                        },
                        // Customize the dot indicators
                        // You can adjust these values according to your preference
                        // dotSize: 4.0,
                        // dotBgColor: Colors.transparent,
                        // dotColor: Colors.grey,
                        // dotIncreasedColor: Color(0xFF000000),
                        // dotSpacing: 15.0,
                      ),
                      // items: imageArray
                      //     .map(
                      //       (element) => Image.network(
                      //     element['src']["original"]!,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ).toList(),
                      items: imageArray
                          .map(
                            (e) => CachedNetworkImage(
                              fadeInDuration: Duration(milliseconds: 0),
                              useOldImageOnUrlChange: true,
                              filterQuality: FilterQuality.low,
                              imageUrl: "${e}",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => AspectRatio(
                                aspectRatio: 200 / 300,
                                child: Container(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          .toList())
                  : Container(
                      child: LinearProgressIndicator(),
                    ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: TextField(
                      cursorColor:Colors.black,
                      // controller: searchControl,
                      // onChanged: onSearchTextChanged,
                      // focusNode: _focusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 15,bottom: 10,right: 10),
                        hintText: 'Search Products...',
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
                  SizedBox(height: 100,),
                  Container(child: Text("Set Amazing Wallpaper",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),),
                  Container(child: Text("By Jas & sneh",style: TextStyle(color: Colors.white),))
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
