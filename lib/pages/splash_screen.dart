// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapak/main.dart';
import 'package:lapak/style/color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void startSplashScreen()async{
    var duration = Duration(seconds: 3);
    Timer(duration,(){
      Get.off(Decision());
    });
  }
  @override
  void initState() {
    startSplashScreen();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: blueTheme,
        body: Center(
          child: Text(
            "L",
            style: TextStyle(
                fontFamily: "popinsemi",
                color: Colors.white,
                fontSize: width / 2),
          ),
        ));
  }
}
