// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, avoid_print, sized_box_for_whitespace

import 'dart:convert';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/models/notif_model.dart';
import 'package:lapak/models/notif_value_model.dart';
import 'package:lapak/style/color.dart';
import 'package:lottie/lottie.dart';
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
  bool isLoading = false;
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

  Future getNotification() async {
    setState(() {
      isLoading = true;
    });
    Uri url = Uri.parse("$baseUrl/checkout/notif");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      return notificationFromJson(res.body);
    } else {
      setState(() {
        isLoading = false;
      });
      print(res.statusCode);
      print(res.body);
    }
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
    getNotif = getNotification();
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
              createdAt: data.createdAt,
              isRead: data.isRead));
        });
      }).toList();
      socket.emit("see_notif", userId);
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
              isLoading
                  ? _loadingState(width)
                  : notif.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(top: width / 6),
                          child: Center(
                              child: LottieBuilder.asset(
                                  "assets/json/4021-no-notification-state.json")),
                        )
                      : Container(
                          height: height,
                          child: GroupedListView<dynamic, DateTime>(
                            elements: notif,
                            groupBy: (data) => DateTime(data.createdAt.year,
                                data.createdAt.month, data.createdAt.day),
                            groupSeparatorBuilder: (DateTime date) => Container(
                              margin:
                                  EdgeInsets.symmetric(vertical: width / 60),
                              child: Text(
                                DateFormat.yMEd().format(date).toString() ==
                                        DateFormat.yMEd().format(DateTime.now())
                                    ? "Hari ini"
                                    : DateFormat.yMEd().format(date).toString(),
                                style: TextStyle(
                                    fontFamily: "popinsemi",
                                    fontSize: width / 27),
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

  Widget _loadingState(width) {
    return StaggeredGrid.count(
      crossAxisCount: 1,
      mainAxisSpacing: width / 30,
      children: [
        Row(
          children: [
            FadeShimmer.round(
              size: width / 7,
              baseColor: Colors.grey.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(
              width: width / 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeShimmer(
                  radius: width / 20,
                  width: width / 2,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: width / 70,
                ),
                FadeShimmer(
                  radius: width / 20,
                  width: width / 4,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            )
          ],
        ),
        Row(
          children: [
            FadeShimmer.round(
              size: width / 7,
              baseColor: Colors.grey.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(
              width: width / 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeShimmer(
                  radius: width / 20,
                  width: width / 2,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: width / 70,
                ),
                FadeShimmer(
                  radius: width / 20,
                  width: width / 4,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            )
          ],
        ),
        Row(
          children: [
            FadeShimmer.round(
              size: width / 7,
              baseColor: Colors.grey.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(
              width: width / 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeShimmer(
                  radius: width / 20,
                  width: width / 2,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: width / 70,
                ),
                FadeShimmer(
                  radius: width / 20,
                  width: width / 4,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            )
          ],
        ),
        Row(
          children: [
            FadeShimmer.round(
              size: width / 7,
              baseColor: Colors.grey.withOpacity(0.2),
              highlightColor: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(
              width: width / 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeShimmer(
                  radius: width / 20,
                  width: width / 2,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: width / 70,
                ),
                FadeShimmer(
                  radius: width / 20,
                  width: width / 4,
                  height: width / 40,
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _notifikasi(width, data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width / 50),
      child: InkWell(
        onTap: () => generateCode(data.from),
        child: Row(
          children: [
            !data.isRead
                ? Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      minRadius: width / 80,
                      maxRadius: width / 80,
                    ),
                  )
                : Container(),
            SizedBox(
              width: width / 40,
            ),
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
            ),
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
