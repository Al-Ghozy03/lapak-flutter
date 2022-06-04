// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/models/notif_value_model.dart';
import 'package:lapak/style/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as Io;

class Notifikasi extends StatefulWidget {
  const Notifikasi({Key? key}) : super(key: key);

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  late Future getNotif;
  List<Notif> notif = [];
  void setStateIfAmount(f) {
    if (mounted) setState(f);
  }

  Io.Socket socket = Io.io('http://192.168.5.220:4003', <String, dynamic>{
    "transports": ["websocket"],
  });
  void connectSocket() {
    socket.onConnect((data) => print("connect"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
  }

  Future generateCode(int id) async {
    print("id $id");
    Uri url = Uri.parse("$baseUrl/chat/generate-code/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      if (jsonDecode(res.body)["code"]["room_code"] != null) {
        socket.emit("join_room", jsonDecode(res.body)["code"]["room_code"]);
        Get.to(
            ChatPage(
                to: jsonDecode(res.body)["code"]["to"],
                roomCode: jsonDecode(res.body)["code"]["room_code"]),
            transition: Transition.rightToLeft);
      } else {
        socket.emit("join_room", jsonDecode(res.body)["code"]["code"]);
        Get.to(
            ChatPage(
                to: int.parse(jsonDecode(res.body)["code"]["to"]),
                roomCode: jsonDecode(res.body)["code"]["code"]),
            transition: Transition.rightToLeft);
      }
    } else {
      print(res.statusCode);
      print(res.body);
    }
  }

  @override
  void initState() {
    connectSocket();
    getNotif = ApiService().getNotification();
    getNotif.then((value) {
      value.data.map((data) {
        setStateIfAmount(() {
          notif.add(Notif(
              name: data.name,
              photoProfile: data.photoProfile,
              from: data.from,
              message: data.message,
              to: data.to,
              id: data.notifId));
        });
      }).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(width / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(width),
              SizedBox(
                height: width / 25,
              ),
              notif.isEmpty
                  ? Container(
                      margin: EdgeInsets.only(top: width / 6),
                      child: Center(
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/no-alarm.png",
                              height: width / 1.6,
                            ),
                            SizedBox(
                              height: width / 20,
                            ),
                            Text(
                              "Kamu tidak memiliki notifikasi apapun",
                              style: TextStyle(
                                  fontSize: width / 20,
                                  fontFamily: "popinsemi",
                                  color: grayText),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
                  : Text(
                      "Hari ini",
                      style: TextStyle(
                          fontFamily: "popinsemi", fontSize: width / 27),
                    ),
              SizedBox(
                height: width / 25,
              ),
              Container(
                height: height,
                child: ListView.separated(
                    itemBuilder: (_, i) {
                      return _notifikasi(width, notif, i);
                    },
                    separatorBuilder: (_, i) {
                      return SizedBox(
                        height: width / 30,
                      );
                    },
                    itemCount: notif.length),
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget _notifikasi(width, data, i) {
    return InkWell(
      onTap: () => generateCode(data[i].from),
      child: Row(
        children: [
          data[i].photoProfile == null
              ? CircleAvatar(
                  maxRadius: width / 17,
                  minRadius: width / 17,
                  backgroundColor: grayBorder,
                  child: Icon(
                    Iconsax.user,
                    size: width / 20,
                    color: grayText,
                  ),
                )
              : CircleAvatar(
                  maxRadius: width / 17,
                  minRadius: width / 17,
                  backgroundImage: NetworkImage(data[i].photoProfile),
                ),
          SizedBox(
            width: width / 27,
          ),
          Flexible(
            child: RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "popin",
                        fontSize: width / 29),
                    children: [
                  TextSpan(
                      text: data[i].name,
                      style: TextStyle(fontFamily: "popinsemi")),
                  TextSpan(text: " ${data[i].message}")
                ])),
          )
        ],
      ),
    );
  }

  Widget _header(width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Iconsax.arrow_left)),
        Text(
          "Notifikasi",
          style: TextStyle(
            fontSize: width / 15,
            fontFamily: "popinsemi",
          ),
        ),
        Text(
          "Chat",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
