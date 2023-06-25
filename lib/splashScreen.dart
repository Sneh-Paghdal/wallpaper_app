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

class _spleshPageState extends State<spleshPage> {

  @override
  initState() {
    super.initState();

    checkInternetConnection();
  }

  //this is for checking internet connection or not
  checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => main_page_view()));

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
      backgroundColor: Colors.white,
      body: Center(
        // child: Text("School",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
          child: Text("splash")
      ),
    );
  }

}

void showToast(BuildContext context,message,bool isBottomsheet,Color color,int height) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 1),
      margin: EdgeInsets.only(bottom: isBottomsheet == true ? MediaQuery.of(context).size.height-height : 20,left: 10,right: 10),
      backgroundColor: color,
      content: Text(message,style: TextStyle(color: Colors.white),),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
