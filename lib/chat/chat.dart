// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, unnecessary_this

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;

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
  TextEditingController message = TextEditingController();
  Io.Socket socket = Io.io('http://192.168.5.220:4003', <String, dynamic>{
    "transports": ["websocket"],
  });
  String token = "";
  int sender = 0;
  void getSender() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    setState(() {
      token = storage.getString("token")!;
      sender = Jwt.parseJwt(token)["id"];
    });
  }

  void connectSocket() {
    socket.onConnect((data) => print("connect $data, ${socket.json}"));
    socket.onConnectError((data) => print("error $data"));
    socket.onDisconnect((data) => print("disconnect"));
    socket.on("received_message", (data) {
      print("data $data");
    });
  }

  void sendMessage() {
    socket.emit("send_message", {
      "message": message.text,
      "from": sender,
      "to": widget.to,
      "room_code": widget.roomCode
    });
    message.clear();
  }

  @override
  void initState() {
    getProfile = ApiService().getProfileChat(widget.to);
    getListMessage = ApiService().listMessage(widget.roomCode);
    super.initState();
    getSender();
    connectSocket();
    socket.connect();
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget _listChat(width, Message message) {
      return Column(
        children: message.data.map((data) {
          return Align(
            alignment: Alignment.centerRight,
            child: _messageFromMe(width),
          );
        }).toList(),
      );
    }

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
              return Text("loading");
            } else if (snapshot.hasError) {
              return Text("terjadi kesalahan");
            } else {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    CircleAvatar(),
                    SizedBox(
                      width: width / 40,
                    ),
                    Text(
                      snapshot.data.data.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "popinsemi",
                          fontSize: width / 20),
                    )
                  ],
                );
              } else {
                return Text("kosong");
              }
            }
          },
        ),
        elevation: 0,
        backgroundColor: Color(0xffF4F4F4),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(width / 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: getListMessage,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Text("loading");
                  } else if (snapshot.hasError) {
                    return Text("terjadi kesalahan");
                  } else {
                    if (snapshot.hasData) {
                      return _listChat(width, snapshot.data);
                    } else {
                      return Text("kosong");
                    }
                  }
                },
              )

              // SizedBox(
              //   height: width / 1.2,
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: message,
              //         decoration: InputDecoration(
              //           hintText: 'Write a message...',
              //           border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(width / 20)),
              //           filled: true,
              //           fillColor: Color(0xffE8E8E8),
              //         ),
              //       ),
              //     ),
              //     IconButton(
              //       onPressed: () {
              //         sendMessage();
              //       },
              //       icon: Icon(Iconsax.send_1),
              //     )
              //   ],
              // )
            ],
          ),
        ),
      )),
    );
  }

  Widget _messageFromOther(width) {
    return Container(
      padding: EdgeInsets.all(width / 20),
      decoration: BoxDecoration(
          color: Color(0xff6495FF),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(width / 20),
              bottomLeft: Radius.circular(width / 20),
              bottomRight: Radius.circular(width / 20))),
      child: Text(
        "Lorem ipsum dolor sit amet,",
        style: TextStyle(fontSize: width / 26, color: Colors.white),
      ),
    );
  }

  Widget _messageFromMe(width) {
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
        "Lorem ipsum dolor sit amet,",
        style: TextStyle(fontSize: width / 26),
      ),
    );
  }

  Widget _header(width) {
    return Container(
      height: width / 5,
      decoration: BoxDecoration(color: Color(0xffF4F4F4)),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Iconsax.arrow_left)),
          CircleAvatar(
            maxRadius: width / 20,
            minRadius: width / 20,
          ),
          SizedBox(
            width: width / 30,
          ),
          Text(
            "Adam",
            style: TextStyle(fontSize: width / 20, fontFamily: "popinsemi"),
          )
        ],
      ),
    );
  }
}
