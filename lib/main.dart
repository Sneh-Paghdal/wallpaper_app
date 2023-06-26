import 'package:flutter/material.dart';
import 'package:wallpaperapp/main_page_view.dart';
import 'package:wallpaperapp/splashScreen.dart';
import 'pages/mainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jasneh - HD, 4K Wallpapers',
      theme: ThemeData(
        primaryColor: const Color(0xFF767676),
        colorScheme: const ColorScheme.light(
          secondary: Color(0xFFE5002A),
        ),
      ),
      home: spleshPage(),
    );
  }
}
