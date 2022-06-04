// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_prefixes, unnecessary_this, unused_field, deprecated_member_use, prefer_collection_literals, avoid_print, use_key_in_widget_constructors, must_be_immutable, unused_local_variable, unused_element, invalid_return_type_for_catch_error, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:lapak/api/api_service.dart';
import 'package:lapak/models/chat_model.dart';
import 'package:lapak/models/message_model.dart';
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
  }

  void sendMessage() {
    socket.emit("send_message", {
      "from": sender,
      "to": widget.to,
      "message": messageController.text,
      "room_code": widget.roomCode,
    });
    messageController.clear();
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void receiveMessage() {
    socket.on("received_message", (data) {
      setStateIfMounted(() {
        messageList.add(ChatModel(
          from: data["from"],
          to: data["to"],
          message: data["message"],
          roomCode: data["room_code"],
        ));
      });
    });
  }

  @override
  void initState() {
    getProfile = ApiService().getProfileChat(widget.to);
    getListMessage = listMessage(widget.roomCode);
    receiveMessage();

    getListMessage.then((value) {
      value.data.map((e) {
        setState(() {
          messageList.add(ChatModel(
              id: e.id,
              from: e.from,
              to: e.to,
              message: e.message,
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
                      snapshot.data.data.name.length >= 22
                          ? "${snapshot.data.data.name.substring(0, 10)}..."
                          : snapshot.data.data.name,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: height,
                child: ListView.builder(
                  itemCount: messageList.length,
                  controller: scrollController,
                  itemBuilder: (_, i) {
                    return Align(
                      alignment: messageList[i].from == sender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: messageList[i].from == sender
                          ? _messageFromMe(width, messageList[i].message)
                          : _messageFromOther(width, messageList[i].message),
                    );
                  },
                ),
              ),
            ),
            _sendArea(width)
          ],
        ),
      )),
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

  Widget _messageFromMe(width, message) {
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
        message.toString(),
        style: TextStyle(fontSize: width / 26),
      ),
    );
  }

  Widget _sendArea(width) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Write a message...',
              contentPadding: EdgeInsets.symmetric(horizontal: width / 50),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width / 20)),
              filled: true,
              fillColor: Color(0xffE8E8E8),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            sendMessage();
          },
          icon: Icon(Iconsax.send_1),
        )
      ],
    );
  }
}
