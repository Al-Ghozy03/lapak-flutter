// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            _header(width),
            
          ],
        ),
      )),
    );
  }

  Widget _header(width) {
    return Container(
      height: width / 5,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 7,
            blurRadius: 30,
            offset: Offset(0, 3))
      ]),
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
