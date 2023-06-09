import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/constDetails.dart';
class categorySection extends StatefulWidget {
  const categorySection({Key? key}) : super(key: key);

  @override
  State<categorySection> createState() => _categorySectionState();
}

class _categorySectionState extends State<categorySection> {

  var natureImage = [];
  var artImage = [];
  var sportImage = [];
  var marvelImage = [];


  getImages() async {
    var headers = {
      'Authorization': contants.apiKey
    };
    var request1 = http.Request(
        'GET',
        Uri.parse(
            'https://api.pexels.com/v1/search?query=nature&per_page=1&orientation=square&size=small&color=black'));
    var request2 = http.Request(
        'GET',
        Uri.parse(
            'https://api.pexels.com/v1/search?query=sport&per_page=1&orientation=square&size=small&color=black'));
    var request3 = http.Request(
        'GET',
        Uri.parse(
            'https://api.pexels.com/v1/search?query=marvel&per_page=1&orientation=square&size=small&color=black'));
    var request4 = http.Request(
        'GET',
        Uri.parse(
            'https://api.pexels.com/v1/search?query=art&per_page=1&orientation=square&size=small&color=black'));
    request1.headers.addAll(headers);
    request2.headers.addAll(headers);
    request3.headers.addAll(headers);
    request4.headers.addAll(headers);
    http.StreamedResponse response1 = await request1.send();
    http.StreamedResponse response2 = await request2.send();
    http.StreamedResponse response3 = await request3.send();
    http.StreamedResponse response4 = await request4.send();
    if (response1.statusCode == 200) {
      var responseBody = await response1.stream.bytesToString();
      var json = jsonDecode(responseBody);

      setState(() {
        natureImage =json['photos'];
      });
      // print(imageArr);
    } else {
      print(response1.reasonPhrase);
    }

    if (response2.statusCode == 200) {
      var responseBody = await response2.stream.bytesToString();
      var json = jsonDecode(responseBody);

      setState(() {
        sportImage =json['photos'];
      });
      setState(() {});
      // print(imageArr);
    } else {
      print(response2.reasonPhrase);
    }

    if (response3.statusCode == 200) {
      var responseBody = await response3.stream.bytesToString();
      var json = jsonDecode(responseBody);

      setState(() {
        marvelImage =json['photos'];
      });
      setState(() {});
      // print(imageArr);
    } else {
      print(response3.reasonPhrase);
    }

    if (response4.statusCode == 200) {
      var responseBody = await response4.stream.bytesToString();
      var json = jsonDecode(responseBody);
      setState(() {
        artImage =json['photos'];
      });
      setState(() {});
      // print(imageArr);
    } else {
      print(response4.reasonPhrase);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImages();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding:EdgeInsets.only(left: 10,right: 10),
      child: Column(
        children: [
          Center(
              child: Text(
                "Category".toUpperCase(),
                style: TextStyle(
                    letterSpacing: 8,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54,width:0.5),
                            image: sportImage.length != 0 ? new DecorationImage(image: new NetworkImage(sportImage[0]['src']["medium"]),
                                fit: BoxFit.cover) : null,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: 100,
                          child: Center(child: Text("Sport",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)),
                        )
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54,width:0.5),
                              image: natureImage.length != 0 ? new DecorationImage(image: new NetworkImage(natureImage[0]['src']["medium"]),
                                  fit: BoxFit.cover) : null,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: 100,
                          child: Center(child: Text("Nature aesthetic",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)),)
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54,width:0.5),
                              image: marvelImage.length != 0 ? new DecorationImage(image: new NetworkImage(marvelImage[0]['src']["medium"]),
                                  fit: BoxFit.cover) : null,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: 100,
                          child: Center(child: Text("Marvel",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)),)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54,width:0.5),
                              image: artImage.length != 0 ? new DecorationImage(image: new NetworkImage(artImage[0]['src']["medium"]),
                                  fit: BoxFit.cover) : null,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: 100,
                          child: Center(child: Text("Art",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)),)
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
