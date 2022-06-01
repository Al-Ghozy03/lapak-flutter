// ignore_for_file: prefer_const_constructors, library_prefixes, unused_import, prefer_typing_uninitialized_variables, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:lapak/pages/dashboard.dart';
import 'package:lapak/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;

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
  final Io.Socket _socket = Io.io("http://192.168.5.220:4003",
      Io.OptionBuilder().setTransports(["websocket"]).build());

  _connectSocket() {
    _socket.onConnect((data) => print("connect"));
    _socket.onConnectError((data) => print("error $data"));
    _socket.onDisconnect((data) => print("disconnect"));
  }

  var token;
  void getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      token = sharedPreferences.getString("token");
    });
  }

  @override
  void initState() {
    getToken();
    super.initState();
    _connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: "popin"),
      debugShowCheckedModeBanner: false,
      home: token == null ? Login() : Dashboard(),
    );
  }
}
