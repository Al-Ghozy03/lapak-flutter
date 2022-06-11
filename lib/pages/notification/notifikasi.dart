// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, avoid_print, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
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

  int userId = 0;
  var lengthNotif = 0.obs;
  void getUserId() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    var token = Jwt.parseJwt(storage.getString("token").toString());
    setState(() {
      userId = token["id"];
    });
  }

  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });
  void connectSocket() {
    socket.onConnect((data) => print("connect"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
  }

  Future generateCode(int id) async {
    Uri url = Uri.parse("$baseUrl/chat/generate-code/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      if (jsonDecode(res.body)["code"]["room_code"] != null) {
        socket.emit("join_room", {
          "room_code": jsonDecode(res.body)["code"]["room_code"],
          "from": userId
        });
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
    getUserId();
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
              id: data.notifId,
              createdAt: data.createdAt));
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
                  : Container(
                      height: height,
                      child: GroupedListView<dynamic, DateTime>(
                        elements: notif,
                        groupBy: (data) => DateTime(data.createdAt.year,
                            data.createdAt.month, data.createdAt.day),
                        groupSeparatorBuilder: (DateTime date) => Container(
                          margin: EdgeInsets.symmetric(vertical: width / 60),
                          child: Text(
                            DateFormat.yMEd().format(date).toString() ==
                                    DateFormat.yMEd().format(DateTime.now())
                                ? "Hari ini"
                                : DateFormat.yMEd().format(date).toString(),
                            style: TextStyle(
                                fontFamily: "popinsemi", fontSize: width / 27),
                          ),
                        ),
                        order: GroupedListOrder.DESC,
                        itemBuilder: (context, dynamic data) {
                          return _notifikasi(width, data);
                        },
                      ),
                    )
            ],
          ),
        )),
      ),
    );
  }

  Widget _notifikasi(
    width,
    data,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width / 50),
      child: InkWell(
        onTap: () => generateCode(data.from),
        child: Row(
          children: [
            data.photoProfile == null
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
                    backgroundImage: NetworkImage(data.photoProfile),
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
                        text: data.name,
                        style: TextStyle(fontFamily: "popinsemi")),
                    TextSpan(text: " ${data.message}")
                  ])),
            )
          ],
        ),
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
