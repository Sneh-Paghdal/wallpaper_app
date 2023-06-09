import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallpaperapp/sections/categorySection.dart';
import 'package:wallpaperapp/sections/sliderSection.dart';

import '../sections/sliderSection2.dart';
class searchTab extends StatefulWidget {
  const searchTab({Key? key}) : super(key: key);

  @override
  State<searchTab> createState() => _searchTabState();
}

class _searchTabState extends State<searchTab> {



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          sliderSection(),
          SizedBox(
            height: 30,
          ),
          categorySection()
        ],
      ),
    );
  }
}
