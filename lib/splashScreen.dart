import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaperapp/main_page_view.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

class spleshPage extends StatefulWidget {
  const spleshPage({Key? key}) : super(key: key);

  @override
  State<spleshPage> createState() => _spleshPageState();
}

class _spleshPageState extends State<spleshPage> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
    checkInternetConnection();
  }

  //this is for checking internet connection or not
  checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        Timer(Duration(seconds: 3),(){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => main_page_view()));
        });
      }
      else {
        // print("internet off");
        showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
          return WillPopScope(
            onWillPop: ()=>Future.value(false),
            child: AlertDialog(
              title: Text("No Internet Connection"),
              content :Text("Your are offline please check your internet connection"),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context,'cancel');
                  checkInternetConnection();
                }, child: Text("ok"))
              ],
            ),
          );
        });
        // showToast(context, "Please turn on your internet.", true, Colors.red, 100);
        // No internet connection
        // Handle the error or show a message to the user
      }
    } on SocketException catch (_) {
      // print("internet off");
      showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
        return WillPopScope(
          onWillPop: ()=>Future.value(false),
          child: AlertDialog(
            title: Text("No Internet Connection"),
            content :Text("Your are offline please check your internet connection"),
            actions: [
              ElevatedButton(onPressed: (){

                Navigator.pop(context,'cancel');
                checkInternetConnection();
              }, child: Text("ok"))
            ],
          ),
        );
      });
      print("////////////////");
      print(_);
      // showToast(context, "Please turn on your internet.", true, Colors.red, 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Container(
        height: 4,
        width: 200,
        margin: EdgeInsets.only(bottom: 30,left: 70,right: 70),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: LinearProgressIndicator(
            backgroundColor: Color(0xFF684dea),
            color: Color(0xFF3bdbe0),
          ),
        ),
      ),
      body: Center(
          child : Container(
            width: MediaQuery.of(context).size.width,
            child: SlideTransition(
              position: _offsetAnimation,
              child: FadeInImage(
                placeholder: AssetImage('assets/images/splashLogo.png'),
                image: AssetImage('assets/images/splashLogo.png'),
              ),
            ),
          )),
    );
  }

}

