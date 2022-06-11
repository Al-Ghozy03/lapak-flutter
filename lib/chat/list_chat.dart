// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/models/list_chat_model.dart';
import 'package:lapak/style/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;

class ListChatPage extends StatefulWidget {
  const ListChatPage({Key? key}) : super(key: key);

  @override
  State<ListChatPage> createState() => _ListChatPageState();
}

class _ListChatPageState extends State<ListChatPage> {
  late Future getListChat;
  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });

  void connectSocket() {
    socket.onConnect((data) => print("connect $data, ${socket.json}"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
  }

  @override
  void initState() {
    connectSocket();
    getListChat = ApiService().getListChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(width / 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(width),
              SizedBox(
                height: width / 30,
              ),
              _listBuilder(width, height)
            ],
          ),
        ),
      )),
    );
  }

  Widget _listBuilder(width, height) {
    return FutureBuilder(
      future: getListChat,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text("loading");
        } else if (snapshot.hasError) {
          return Text("terjadi kesalahan");
        } else {
          if (snapshot.hasData) {
            return _list(width, snapshot.data, height);
          } else {
            return Text("kosong");
          }
        }
      },
    );
  }

  Widget _list(width, ListChat chat, height) {
    return Container(
      height: height * 1.2,
      child: ListView.separated(
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () async {
                SharedPreferences storage =
                    await SharedPreferences.getInstance();
                var userId =
                    Jwt.parseJwt(storage.getString("token").toString());

                socket.emit("join_room",
                    {"room_code": chat.data[i].roomCode, "from": userId["id"]});
                Get.to(
                    ChatPage(
                      to: chat.data[i].receiver,
                      roomCode: chat.data[i].roomCode,
                    ),
                    transition: Transition.rightToLeft);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chat.data[i].photoProfile == null
                          ? CircleAvatar(
                              maxRadius: width / 17,
                              minRadius: width / 17,
                              backgroundColor: grayBorder,
                              child: Icon(
                                Iconsax.user,
                                color: grayText,
                                size: width / 20,
                              ),
                            )
                          : CircleAvatar(
                              maxRadius: width / 17,
                              minRadius: width / 17,
                              backgroundImage:
                                  NetworkImage(chat.data[i].photoProfile),
                            ),
                      SizedBox(
                        width: width / 30,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.data[i].name,
                            style: TextStyle(
                                fontFamily: "popinsemi", fontSize: width / 25),
                          ),
                          // Text(
                          //   "okok",
                          //   style: TextStyle(
                          //       fontSize: width / 33, color: grayText),
                          // )
                        ],
                      )
                    ],
                  ),
                  // Column(
                  //   children: [
                  //     Text("20.30"),
                  //     CircleAvatar(
                  //       backgroundColor: blueTheme,
                  //       minRadius: width / 38,
                  //       maxRadius: width / 38,
                  //       child: Text("1"),
                  //     )
                  //   ],
                  // )
                ],
              ),
            );
          },
          separatorBuilder: (_, i) {
            return SizedBox(
              height: width / 16,
            );
          },
          itemCount: chat.data.length),
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
          "Chat",
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
