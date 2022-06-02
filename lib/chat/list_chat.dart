// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lapak/chat/chat.dart';
import 'package:lapak/style/color.dart';
import 'package:lapak/widget/custom_route.dart';

class ListChat extends StatefulWidget {
  const ListChat({Key? key}) : super(key: key);

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(width / 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(width),
              SizedBox(
                height: width / 10,
              ),
              TextField(
                decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(fontSize: width / 32),
                    prefixIcon: Icon(Iconsax.search_normal_1),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width / 40),
                        borderSide: BorderSide(width: 3, color: grayBorder)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width / 40),
                        borderSide: BorderSide(width: 3, color: grayBorder))),
              ),
              SizedBox(
                height: width / 12,
              ),
              _list(width)
            ],
          ),
        ),
      )),
    );
  }

  Widget _list(width) {
    return InkWell(
      onTap: () => Navigator.of(context).push(CustomPageRoute(child: ChatPage(to: 1,roomCode: "",))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: width / 17,
                minRadius: width / 17,
              ),
              SizedBox(
                width: width / 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Adam",
                    style: TextStyle(
                        fontFamily: "popinsemi", fontSize: width / 25),
                  ),
                  Text(
                    "okok",
                    style: TextStyle(fontSize: width / 33, color: grayText),
                  )
                ],
              )
            ],
          ),
          Column(
            children: [
              Text("20.30"),
              CircleAvatar(
                backgroundColor: blueTheme,
                minRadius: width / 38,
                maxRadius: width / 38,
                child: Text("1"),
              )
            ],
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
