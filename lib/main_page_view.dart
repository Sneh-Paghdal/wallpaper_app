import 'package:flutter/material.dart';
import 'package:wallpaperapp/pages/favorites_page.dart';
import 'package:wallpaperapp/pages/mainPage.dart';

class main_page_view extends StatefulWidget {
  const main_page_view({Key? key}) : super(key: key);

  @override
  State<main_page_view> createState() => _main_page_viewState();
}

class _main_page_viewState extends State<main_page_view> {
  final _controller = PageController(
    initialPage: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          favorite_page(),
          MainPage()
        ],
      ),
    );
  }
}
