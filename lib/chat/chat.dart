// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, unnecessary_this, unused_field, deprecated_member_use, prefer_collection_literals, avoid_print, use_key_in_widget_constructors, must_be_immutable, unused_local_variable, unused_element, invalid_return_type_for_catch_error, sized_box_for_whitespace, prefer_final_fields

import 'dart:convert';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/models/chat_model.dart';
import 'package:lapak/models/info_model.dart';
import 'package:lapak/models/message_model.dart';
import 'package:lapak/service/api_service.dart';
import 'package:lapak/service/notification_service.dart';
import 'package:lapak/style/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  int to;
  String roomCode;
  ChatPage({required this.to, required this.roomCode});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future getProfile;
  late Future getListMessage;
  List<ChatModel> messageList = [];
  ChatModel? chatModel;
  ScrollController scrollController = ScrollController();
  Info _info = Info(name: "", alamat: "");
  bool reverse = true;

  void getInfo() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    Map<String, dynamic> info = {};
    String infoStr = storage.getString("info").toString();

    setState(() {
      info = jsonDecode(infoStr) as Map<String, dynamic>;
      _info = Info.fromJson(info);
    });
  }

  Future listMessage(String roomCode) async {
    Uri url = Uri.parse("$baseUrl/chat/list-message/$roomCode");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return messageFromJson(res.body);
    } else {
      print(res.statusCode);
      print(res.body);
      return false;
    }
  }

  TextEditingController messageController = TextEditingController();
  Io.Socket socket = Io.io(baseUrl, <String, dynamic>{
    "transports": ["websocket"],
  });
  String token = "";
  int sender = 0;
  String user = "";
  void getSender() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      token = storage.getString("token")!;
      sender = Jwt.parseJwt(token)["id"];
    });
  }

  void connectSocket() {
    socket.onConnect((data) => print("connect"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    getInfo();
    socket.on("received_message", (data) {
      if (data["to"] == sender) {
        NotificationService.showNotification(
            title: "Pesan baru dari $user",
            body: data["message"],
            payload: "message");
      } else {
        print("not showing notif");
      }
      setStateIfMounted(() {
        messageList.add(ChatModel(
            from: data["from"],
            to: data["to"],
            message: data["message"],
            roomCode: data["room_code"],
            isRead: data["is_read"],
            createdAt: DateTime.parse(data["createdAt"]),
            updatedAt: DateTime.parse(data["updatedAt"])));
      });
    });
    getProfile = ApiService().getProfileChat(widget.to);
    getListMessage = listMessage(widget.roomCode);
    getListMessage.then((value) {
      value.data.map((e) {
        setState(() {
          messageList.add(ChatModel(
              from: e.from,
              to: e.to,
              message: e.message,
              isRead: e.isRead,
              roomCode: e.roomCode,
              createdAt: e.createdAt,
              updatedAt: e.updatedAt));
        });
      }).toList();
    }).catchError((onError) => print(onError));

    super.initState();
    getSender();
    connectSocket();
    socket.connect();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width / 5,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Iconsax.arrow_left)),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: FutureBuilder(
          future: getProfile,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _loadingState(width);
            } else if (snapshot.hasError) {
              return _loadingState(width);
            } else {
              if (snapshot.hasData) {
                user = snapshot.data.data.name;
                return Row(
                  children: [
                    snapshot.data.data.photoProfile == null
                        ? CircleAvatar(
                            backgroundColor: grayBorder,
                            child: Icon(
                              Iconsax.user,
                              color: grayText,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: grayBorder,
                            backgroundImage:
                                NetworkImage(snapshot.data.data.photoProfile),
                          ),
                    SizedBox(
                      width: width / 40,
                    ),
                    Text(
                      snapshot.data.data.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "popinsemi",
                          fontSize: width / 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                );
              } else {
                return _loadingState(width);
              }
            }
          },
        ),
        elevation: 0,
        backgroundColor: Color(0xffF4F4F4),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.all(width / 25),
            height: height,
            child: GroupedListView<dynamic, DateTime>(
              controller: scrollController,
              elements: messageList,
              groupBy: (data) => DateTime(data.createdAt.year,
                  data.createdAt.month, data.createdAt.day),
              groupSeparatorBuilder: (DateTime date) => Center(
                  child: Text(
                DateFormat.yMEd().format(date).toString() ==
                        DateFormat.yMEd().format(DateTime.now())
                    ? "Hari ini"
                    : DateFormat.yMEd().format(date).toString(),
                style: TextStyle(fontSize: width / 35),
              )),
              order: GroupedListOrder.ASC,
              itemBuilder: (context, dynamic data) {
                return Align(
                  alignment: data.from == sender
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: data.from == sender
                      ? _messageFromMe(width, data.message, data.isRead)
                      : _messageFromOther(width, data.message),
                );
              },
            ),
          )),
          _sendArea(width)
        ],
      )),
    );
  }

  Widget _loadingState(width) {
    return Row(
      children: [
        FadeShimmer.round(
          size: width / 9,
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
    );
  }

  Widget _messageFromOther(width, message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width / 60),
      padding: EdgeInsets.all(width / 25),
      decoration: BoxDecoration(
          color: Color(0xff6495FF),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(width / 20),
              bottomLeft: Radius.circular(width / 20),
              bottomRight: Radius.circular(width / 20))),
      child: Text(
        message.toString(),
        style: TextStyle(fontSize: width / 26, color: Colors.white),
      ),
    );
  }

  Widget _messageFromMe(width, message, isRead) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width / 60),
      padding: EdgeInsets.all(width / 25),
      decoration: BoxDecoration(
          color: Color(0xffEBEBEB),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(width / 20),
              bottomLeft: Radius.circular(width / 20),
              bottomRight: Radius.circular(width / 20))),
      child: Text(
        "$message",
        style: TextStyle(fontSize: width / 26),
      ),
    );
  }

  Widget _sendArea(width) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: width / 25, horizontal: width / 40),
      color: Color.fromARGB(255, 236, 236, 236).withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Write a message...',
                contentPadding: EdgeInsets.symmetric(horizontal: width / 50),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              socket.emit("send_message", {
                "sender": user,
                "from": sender,
                "to": widget.to,
                "message": messageController.text,
                "room_code": widget.roomCode,
                "is_read": false,
                "createdAt": DateTime.now().toString(),
                "updatedAt": DateTime.now().toString(),
              });
              messageController.clear();
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOut);
            },
            icon: Icon(Iconsax.send_1),
          )
        ],
      ),
    );
  }
}
