// ignore_for_file: prefer_const_constructors, library_prefixes, unused_import, prefer_typing_uninitialized_variables, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/pages/auth/login.dart';
import 'package:lapak/pages/dashboard.dart';
import 'package:lapak/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: "Lapak Online Shop",
        theme: ThemeData(fontFamily: "popin"),
        debugShowCheckedModeBanner: false,
        home: SplashScreen());
  }
}

class Decision extends StatefulWidget {
  const Decision({super.key});

  @override
  State<Decision> createState() => _DecisionState();
}

class _DecisionState extends State<Decision> {
  var token;
  void getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      token = storage.getString("token");
    });
  }


  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: token == null ? Login() : Dashboard(),
    );
  }
}
